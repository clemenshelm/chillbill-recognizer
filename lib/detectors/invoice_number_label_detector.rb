# frozen_string_literal: true
require_relative '../models/invoice_number_label_term'

class InvoiceNumberLabelDetector
  INVOICE_NUMBER_LABELS = /(Re-Nr:)/

  def self.filter
    end_word_with_space = ->(term) { term.text += ' ' }
    find_invoice_number_labels(
      INVOICE_NUMBER_LABELS,
      after_each_word: end_word_with_space
    )
    InvoiceNumberLabelTerm.dataset
  end

  class << self
    private

      def find_invoice_number_labels(regex, after_each_word: nil)
        term = InvoiceNumberLabelTerm.new(
          regex: regex, after_each_word: after_each_word, max_words: 2
        )
        last_word = nil

        Word.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = InvoiceNumberLabelTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 2
            )
          end

          term.add_word(word)

          last_word = word

          term.save if term.valid?
        end
      end
  end
end
