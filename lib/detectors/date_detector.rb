require_relative '../word_list'
require_relative '../models/date_term'

class DateDetector
  SHORT_PERIOD_DATE_REGEX = /[0123]?\d\.(?:0?1|0?2|0?3|0?4|0?5|0?6|0?7|0?8|0?9|10|11|12)\.\d+/
  SHORT_SLASH_DATE_REGEX = /[0123]?\d\/(?:0?1|0?2|0?3|0?4|0?5|0?6|0?7|0?8|0?9|10|11|12)\/\d+/
  FULL_GERMAN_DATE_REGEX = /\d+\. (?:März|April) \d+/
  FULL_ENGLISH_DATE_REGEX = /\d+ March \d+/

  def self.filter
    end_number_with_period = -> (term) { term.text += '.' if term.text =~ /\d$/ }
    find_dates(SHORT_PERIOD_DATE_REGEX, after_each_word: end_number_with_period)

    find_dates(SHORT_SLASH_DATE_REGEX)

    end_word_with_space = -> (term) { term.text += ' ' }
    find_dates(FULL_GERMAN_DATE_REGEX, after_each_word: end_word_with_space)

    find_dates(FULL_ENGLISH_DATE_REGEX, after_each_word: end_word_with_space)

    DateTerm.order(:first_word_id)
  end

  private

  def self.find_dates(regex, after_each_word: nil)
    term = DateTerm.new(regex: regex, after_each_word: after_each_word)

    Word.each do |word|
      unless term.new?
        term = DateTerm.new(regex: regex, after_each_word: after_each_word)
      end
      term.add_word(word)

      if term.valid?
        term.save
      end
    end
  end
end
