# frozen_string_literal: true
require_relative '../models/invoice_number_label_term'

class InvoiceNumberLabelDetector
  INVOICE_NUMBER_LABELS = %w(
    Re-Nr: Bon-ID Rech.Nr: Beleg-nr.: Rechnungsnummer: Rechnung: Rechnungsnummer
  ).freeze
  MULTI_WORD_INVOICE_NUMBER_LABELS_REGEX =
    /(Invoice number:|Billing ID:|Rechnung Nr.:)/

  def self.filter
    invoice_number_label_regexes =
      /#{INVOICE_NUMBER_LABELS.map { |s| Regexp.quote(s) }.join('|')}/
    end_word_with_space = ->(term) { term.text += ' ' }

    find_invoice_number_labels(
      MULTI_WORD_INVOICE_NUMBER_LABELS_REGEX,
      after_each_word: end_word_with_space
    )
    find_invoice_number_labels(invoice_number_label_regexes)

    InvoiceNumberLabelTerm.dataset
  end

  class << self
    private

      def find_invoice_number_labels(regex, after_each_word: nil)
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = InvoiceNumberLabelTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 2
            )
          end

          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
