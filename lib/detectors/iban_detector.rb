# frozen_string_literal: true
require_relative '../models/iban_term'

class IbanDetector
  AT_IBAN_REGEX = /AT[0-9]{18}/
  DE_IBAN_REGEX = /DE[0-9]{20}/
  HR_IBAN_REGEX = /HR[0-9]{19}/

  def self.filter
    find_iban(AT_IBAN_REGEX)
    find_iban(DE_IBAN_REGEX)
    find_iban(HR_IBAN_REGEX)
    IbanTerm.dataset
  end

  class << self
    private

      def find_iban(regex, after_each_word: nil)
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = IbanTerm.new(
              regex: regex,
              after_each_word: after_each_word,
              max_words: 5
            )
          end
          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
