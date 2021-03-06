# frozen_string_literal: true
require_relative '../boot'
require_relative '../models/invoice_number_term'

class InvoiceNumberDetector
  COMMON_SHOP_RECEIPT_NUMBER_REGEX = /\d{4}-\d{8}-\d{2}-\d{4}/
  SPAR_RECEIPT_NUMBER_REGEX = /\d{4} \d{2} \d{4} \d{6} \d{4}/
  DRIVE_NOW_INVOICE_NUMBER_REGEX = %r(\d{10}\/00\/M\/00\/N)
  A1_INVOICE_NUMBER_REGEX = /\d{12}/
  EASYNAME_INVOICE_NUMBER_REGEX = /RE\d{7}/
  GOOGLE_INVOICE_NUMBER_REGEX = /((\d{12,16}-\d{1,2})|(\d{4}-\d{4}-\d{4}))/
  HOFER_INVOICE_NUMBER_REGEX = %r(\d{4} \d{3}\/\d{3}\/\d{3}\/\d{2})
  DRUCK_INVOICE_NUMBER_REGEX = /\d{14}/
  LABELLED_FIVE_DIGIT_INVOICE_NUMBER_REGEX = /\d{5}/
  TEN_DIGIT_DREI_INVOICE_NUMBER_REGEX = /\d{10}/
  FOUR_DIGIT_DREI_INVOICE_NUMBER_REGEX = /\d{4}/
  AMAZON_INVOICE_NUMBER_REGEX = /EUVINS1-OFS-[A-Z]{2}-\d{8}/

  def self.filter
    reduced_words = filter_out_interfering_invoice_numbers
    reduced_words -= find_invoice_numbers(
      Word.all, GOOGLE_INVOICE_NUMBER_REGEX, max_words: 1
    )
    reduced_words -= find_invoice_numbers(
      reduced_words, DRUCK_INVOICE_NUMBER_REGEX, max_words: 1
    )
    reduced_words -= find_invoice_numbers(
      reduced_words, A1_INVOICE_NUMBER_REGEX, max_words: 1
    )
    reduced_words -= find_invoice_numbers(
      reduced_words, TEN_DIGIT_DREI_INVOICE_NUMBER_REGEX, max_words: 1
    )
    reduced_words -= find_invoice_numbers(
      reduced_words, LABELLED_FIVE_DIGIT_INVOICE_NUMBER_REGEX, max_words: 1
    )
    find_invoice_numbers(
      reduced_words, FOUR_DIGIT_DREI_INVOICE_NUMBER_REGEX, max_words: 1
    )
    InvoiceNumberTerm.dataset
  end

  def self.filter_out_interfering_invoice_numbers
    end_word_with_space = ->(term) { term.text += ' ' }

    words = find_invoice_numbers(
      Word.all, DRIVE_NOW_INVOICE_NUMBER_REGEX, max_words: 1
    )
    words += find_invoice_numbers(
      Word.all, AMAZON_INVOICE_NUMBER_REGEX, max_words: 1
    )
    words += find_invoice_numbers(
      Word.all, EASYNAME_INVOICE_NUMBER_REGEX, max_words: 1
    )
    words += find_invoice_numbers(
      Word.all, COMMON_SHOP_RECEIPT_NUMBER_REGEX, max_words: 1
    )
    words += find_invoice_numbers(
      Word.all,
      HOFER_INVOICE_NUMBER_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2,
      needs_label: false
    )
    words += find_invoice_numbers(
      Word.all,
      SPAR_RECEIPT_NUMBER_REGEX,
      after_each_word: end_word_with_space,
      max_words: 5
    )
    Word.all - words
  end

  class << self
    private

      def find_invoice_numbers(
        words, regex, after_each_word: nil, max_words: nil, needs_label: true
      )
        affected_words = []
        term = nil
        last_word = nil
        term_stale = true

        words.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = InvoiceNumberTerm.new(
              regex: regex,
              after_each_word: after_each_word,
              max_words: max_words,
              needs_label: needs_label
            )
          end
          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
          affected_words += term.words if term_stale
        end
        affected_words
      end
  end
end
