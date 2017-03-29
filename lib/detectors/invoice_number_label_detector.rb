# frozen_string_literal: true
require_relative '../models/invoice_number_label_term'

class InvoiceNumberLabelDetector
  INVOICE_NUMBER_LABELS_REGEX = /(Re-Nr:|Bon-ID|Rech.Nr:|Beleg-nr.:)/
  SINGLE_WORD_INVOICE_NUMBER_LABELS_REGEX =
    /(Rechnungsnummer:|Rechnung:|Rechnungsnummer)/
  MULTI_WORD_INVOICE_NUMBER_LABELS_REGEX =
    /(Invoice number:|Billing ID|Rechnung Nr.:)/
  def self.filter
    end_word_with_space = ->(term) { term.text += ' ' }

    find_invoice_number_labels(
      MULTI_WORD_INVOICE_NUMBER_LABELS_REGEX,
      after_each_word: end_word_with_space
    )
    find_invoice_number_labels(SINGLE_WORD_INVOICE_NUMBER_LABELS_REGEX)
    find_invoice_number_labels(INVOICE_NUMBER_LABELS_REGEX)

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
