require_relative '../../lib/boot'
require_relative '../word_list'
require_relative '../models/date_term'

class DateDetector
  months = ((1..9).map { |n| "0?#{n}" } + (10..12).to_a).join('|')
  days = ((1..9).map { |n| "0?#{n}" } + (10..31).to_a).join('|')
  SHORT_PERIOD_DATE_REGEX = /(?:^|[^+\d])((?:#{days})\.(?:#{months})\.\d+)/
  SHORT_SLASH_DATE_REGEX = /((?:#{days})\/(?:#{months})\/\d+)/
  FULL_GERMAN_DATE_REGEX = /(\d+\. (?:März|April|Dezember) \d+)/
  FULL_ENGLISH_DATE_REGEX = /(\d+ March \d+)/
  ENGLISH_COMMA_DATE_REGEX = /Jun|Jul \d*, \d+/
  ISO_DATE_REGEX = /((?:#{days})\-(?:#{months})\-\d+)/


  def self.filter
    date_terms = []
    end_number_with_period = -> (term) { term.text += '.' if term.text =~ /\d$/ }
    date_terms += find_dates(SHORT_PERIOD_DATE_REGEX, after_each_word: end_number_with_period)

    date_terms += find_dates(SHORT_SLASH_DATE_REGEX)

    end_word_with_space = -> (term) { term.text += ' ' }
    date_terms += find_dates(FULL_GERMAN_DATE_REGEX, after_each_word: end_word_with_space)

    date_terms += find_dates(ENGLISH_COMMA_DATE_REGEX, after_each_word: end_word_with_space)
    date_terms += find_dates(ISO_DATE_REGEX, after_each_word: end_word_with_space)

    date_terms += find_dates(ENGLISH_COMMA_DATE_REGEX, after_each_word: end_word_with_space)

    most_used_regex = date_terms.group_by(&:regex).sort{|regex, terms| terms.count}.last.first
    date_terms.select{|term| term.regex == most_used_regex }.each(&:save)

    DateTerm.order(:first_word_id)
  end

  private

  def self.find_dates(regex, after_each_word: nil)
    term = DateTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    terms = Word.map do |word|
      if term.valid? || (last_word && !word.follows(last_word))
        term = DateTerm.new(regex: regex, after_each_word: after_each_word)
      end
      term.add_word(word)
      last_word = word
      if term.valid?
        term
      end
    end
    terms.compact
  end
end
