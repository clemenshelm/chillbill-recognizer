# frozen_string_literal: true
require_relative '../models/invoice_date_label_term'

class InvoiceDateLabelDetector
  INVOICE_DATE_LABELS = /Rechnungsdatum:/

  def self.filter
    find_invoice_date_labels(INVOICE_DATE_LABELS)
    InvoiceDateLabelTerm.dataset
  end

  class << self
    private

      def find_invoice_date_labels(regex, after_each_word: nil)
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = InvoiceDateLabelTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 1
            )
          end

          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
