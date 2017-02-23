# frozen_string_literal: true
require_relative '../models/invoice_number_term'

class InvoiceNumberDetector
  COMMON_SHOP_RECEIPT_NUMBER =
    /\d{4}-\d{8}-\d{2}-\d{4}/

  def self.filter
    find_possible_invoice_numbers(COMMON_SHOP_RECEIPT_NUMBER)

    InvoiceNumberTerm.dataset
  end

  class << self
    private

      def find_possible_invoice_numbers(
        regex, after_each_word: nil, max_words: nil
      )
        term = initialize_new_term(regex, after_each_word, max_words)
        last_word = nil

        Word.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = initialize_new_term(regex, after_each_word, max_words)
          end
          term.add_word(word)
          last_word = word

          term.save if term.valid?
        end
      end

      def initialize_new_term(regex, after_each_word, max_words)
        InvoiceNumberTerm.new(
          regex: regex,
          after_each_word: after_each_word,
          max_words: max_words
        )
      end
  end
end
