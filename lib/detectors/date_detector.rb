# frozen_string_literal: true
require_relative '../boot'
require_relative '../models/date_term'

class DateDetector
  months = ((1..9).map { |n| "0?#{n}" } + (10..12).to_a).join('|')
  days = ((1..9).map { |n| "0?#{n}" } + (10..31).to_a).join('|')

  SHORT_PERIOD_DATE_REGEX =
    /(?:^|[^+\d])((?:#{days})\.(?:#{months})\.((?:20)?1\d))/
  SHORT_SLASH_DATE_REGEX = %r{(^(#{days})/(#{months})/\d{2}$)}
  LONG_YEAR_SLASH_REGEX = %r{^\d{4}/(?:#{months})/(?:#{days})$}
  LONG_HYPHEN_DATE_REGEX = /((?:#{days})-(?:#{months})-20\d{2}$)/
  SHORT_ENGLISH_DATE_REGEX = /((?:#{days})-(?:Oct)-\d{4}$)/
  SHORT_ENGLISH_DATE_WITH_SPACE_REGEX = /((?:#{days}) (?:Jul) \d{4})/
  LONG_SLASH_DATE_REGEX = %r{((?:#{days})/(?:#{months})/\d{4}$)}
  AMERICAN_LONG_SLASH_DATE_REGEX = %r{((?:#{months})/(?:#{days})/\d{4}$)}
  FULL_GERMAN_DATE_REGEX =
    /(\d+\. (?:Februar|März|April|August|September|Oktober|Dezember) \d{4})/
  FULL_ENGLISH_DATE_REGEX = /(\d{2} (?:March|May|October) \d{4})/
  LONG_HUNGARIAN_DATE_REGEX = /20\d{2}\.(?:#{months})\.(?:#{days})/
  FULL_ENGLISH_COMMA_DATE_REGEX = /((?:August) \d{2}\, \d{4})/

  def self.filter
    reduced_words = filter_out_interefering_date_terms
    find_long_dates_with_periods(reduced_words)

    find_multi_word_dates(reduced_words)
    find_dates(reduced_words, SHORT_SLASH_DATE_REGEX, max_words: 1)
    find_dates(reduced_words, SHORT_ENGLISH_DATE_REGEX, max_words: 1)
    find_dates(reduced_words, AMERICAN_LONG_SLASH_DATE_REGEX, max_words: 1)
    find_dates(reduced_words, LONG_HYPHEN_DATE_REGEX, max_words: 1)
    find_dates(reduced_words, LONG_HUNGARIAN_DATE_REGEX, max_words: 1)

    DateTerm.order(:first_word_id)
  end

  def self.filter_out_interefering_date_terms
    words = find_dates(Word.all, LONG_SLASH_DATE_REGEX, max_words: 1)
    words += find_dates(Word.all, SHORT_PERIOD_DATE_REGEX, max_words: 6)
    words += find_dates(Word.all, LONG_YEAR_SLASH_REGEX, max_words: 1)
    Word.all - words
  end

  def self.find_long_dates_with_periods(words)
    end_number_with_period = lambda do |term|
      term.text += '.' if term.text =~ /^\d{2}$/
    end

    find_dates(
      words,
      SHORT_PERIOD_DATE_REGEX,
      after_each_word: end_number_with_period,
      max_words: 3
    )
  end

  def self.find_multi_word_dates(words)
    end_word_with_space = ->(term) { term.text += ' ' }
    find_dates(
      words, FULL_GERMAN_DATE_REGEX,
      after_each_word: end_word_with_space, max_words: 3
    )

    find_dates(
      words, FULL_ENGLISH_DATE_REGEX,
      after_each_word: end_word_with_space, max_words: 3
    )

    find_dates(
      words, FULL_ENGLISH_COMMA_DATE_REGEX,
      after_each_word: end_word_with_space, max_words: 3
    )

    find_dates(
      words, SHORT_ENGLISH_DATE_WITH_SPACE_REGEX,
      after_each_word: end_word_with_space, max_words: 3
    )
  end

  class << self
    private

      def find_dates(words, regex, after_each_word: nil, max_words: nil)
        affected_words = []
        term = nil
        last_word = nil
        term_stale = true

        words.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = DateTerm.new(
              regex: regex,
              after_each_word: after_each_word,
              max_words: max_words
            )
          end
          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
          affected_words += term.words if term_stale
        end
        affected_words
      end
  end
end
