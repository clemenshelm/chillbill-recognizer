require_relative '../word_list'
require_relative '../models/date_term'

class DateDetector
  SHORT_GERMAN_DATE_REGEX = /(?:^|\D)([0123]?\d\.(?:0?1|0?2|0?3|0?4|0?5|0?6|0?7|0?8|0?9|10|11|12)\.\d+)/
  FULL_GERMAN_DATE_REGEX = /\d+\. April \d+/

  def self.filter
    end_number_with_period = -> (term) { term.text += '.' if term.text =~ /\d$/ }
    find_dates(SHORT_GERMAN_DATE_REGEX, after_each_word: end_number_with_period)

    end_word_with_space = -> (term) { term.text += ' ' }
    find_dates(FULL_GERMAN_DATE_REGEX, after_each_word: end_word_with_space)

    DateTerm.dataset
  end

  private

  def self.find_dates(regex, after_each_word:)
    term = DateTerm.new

    Word.each do |word|
      term = DateTerm.new unless term.new?
      term.add_word(word)

      after_each_word.call(term)

      date_string = term.text.scan(regex).first

      if date_string
        term.text = date_string
        term.save
      end
    end
  end
end
