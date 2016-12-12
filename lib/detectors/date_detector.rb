# frozen_string_literal: true
require_relative '../boot'
require_relative '../models/date_term'

class DateDetector
  months = ((1..9).map { |n| "0?#{n}" } + (10..12).to_a).join('|')
  days = ((1..9).map { |n| "0?#{n}" } + (10..31).to_a).join('|')
  SHORT_PERIOD_DATE_REGEX = /(?:^|[^+\d])((?:#{days})\.(?:#{months})\.\d+)/
  SHORT_SLASH_DATE_REGEX = %r{((?:#{days})/(?:#{months})/\d{2}$)}
  LONG_SLASH_DATE_REGEX = %r{((?:#{days})/(?:#{months})/\d{4}$)}
  FULL_GERMAN_DATE_REGEX = /(\d+\. (?:März|April|Dezember) \d+)/
  FULL_ENGLISH_DATE_REGEX = /(\d+ (?:March|May|October) \d+)/
  LONG_HUNGARIAN_DATE_REGEX = /\d{4}\.(?:#{months})\.(?:#{days})/
  LONG_HYPHEN_DATE_REGEX = /((?:#{days})-(?:#{months})-\d{4}$)/

  def self.filter
    end_number_with_period = lambda do |term|
      term.text += '.' if term.text =~ /\d$/
    end
    find_dates(
      SHORT_PERIOD_DATE_REGEX,
      after_each_word: end_number_with_period,
      max_words: 3
    )
    find_dates(SHORT_SLASH_DATE_REGEX, max_words: 1)
    find_dates(LONG_SLASH_DATE_REGEX, max_words: 1)
    find_dates(LONG_HUNGARIAN_DATE_REGEX, max_words: 1)
    find_dates(LONG_HYPHEN_DATE_REGEX, max_words: 1)

    end_word_with_space = -> (term) { term.text += ' ' }
    find_dates(
      FULL_GERMAN_DATE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 3
    )
    find_dates(
      FULL_ENGLISH_DATE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 3
    )

    DateTerm.order(:first_word_id)
  end

  def self.find_dates(regex, after_each_word: nil, max_words: nil)
    private
    term = DateTerm.new(
      regex: regex,
      after_each_word: after_each_word,
      max_words: max_words
    )
    last_word = nil

    Word.each do |word|
      if term.exists? || (last_word && !word.follows(last_word))
        term = DateTerm.new(
          regex: regex,
          after_each_word: after_each_word,
          max_words: max_words
        )
      end
      term.add_word(word)

      last_word = word

      term.save if term.valid?
    end
  end
end
