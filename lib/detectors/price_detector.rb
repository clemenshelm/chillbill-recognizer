# frozen_string_literal: true
require 'ostruct'
require 'bigdecimal'
require_relative '../models/price_term'
require_relative '../detectors/currency_detector'
require_relative '../models/dimensionable'

class PriceDetector
  include Dimensionable
  PRICE_REGEX = /(-?[1-9]{1}\d{0,3}|0)([\.,]\d{3})?[,\.](\d{2}€?|-)/
  PREFIX_CURRENCY_REGEX = /(€|EUR)/
  ALLOWED_PREFIX_REGEX = /(?:^|[^\d,A-Za-z\.-])/
  DECIMAL_PRICE_REGEX =
    /#{ALLOWED_PREFIX_REGEX}(#{PREFIX_CURRENCY_REGEX}?#{PRICE_REGEX})$/
  WRITTEN_PRICE_REGEX = /(\d+ Euro)/
  SHORT_PRICE_REGEX = /^(\d+€)$/
  HUNGARIAN_PRICE_REGEX = /^(\d{2} \d{3})$/

  def self.filter_out_quantity_column
    %w(Menge Anz.).each do |quantity_text|
      quantity = Word.first(text: quantity_text)
      next unless quantity
      PriceTerm.each do |term|
        term.destroy if in_same_column(quantity, term)
      end
    end
  end

  def self.filter_out_dates
    PriceTerm.each do |term|
      term.destroy if Word.two_words_after_matches?(term, /\./, /^\d{2}$/)
    end
  end

  def self.filter
    find_prices(DECIMAL_PRICE_REGEX, max_words: 3)
    filter_out_quantity_column
    filter_out_dates

    end_word_with_space = ->(term) { term.text += ' ' }
    unless Word.where(text: CurrencyDetector::HUF_SYMBOLS).empty?
      find_prices(
        HUNGARIAN_PRICE_REGEX,
        after_each_word: end_word_with_space,
        max_words: 2
      )
    end

    find_prices(
      WRITTEN_PRICE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2
    )

    find_prices(SHORT_PRICE_REGEX, max_words: 1)
    PriceTerm.dataset
  end

  class << self
    private

      def find_prices(regex, after_each_word: nil, max_words: nil)
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale
            term = PriceTerm.new(
              regex: regex,
              after_each_word: after_each_word,
              max_words: max_words
            )
          end
          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
