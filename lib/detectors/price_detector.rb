# frozen_string_literal: true
require 'ostruct'
require 'bigdecimal'
require_relative '../models/price_term'

class PriceDetector
  DECIMAL_PRICE_REGEX =
    /(?:^|[^\.,\d])(€?\d{1,4}(?:[\.,]\d{3})?+[,\.](?:\d{2,3}|-))(?:[^\.\d%]|$)/
  WRITTEN_PRICE_REGEX = /(\d+ Euro)/
  SHORT_PRICE_REGEX = /(\d+€)/
  HUNGARIAN_PRICE_REGEX = /^[0-9]{2} [0-9]{3}/

  def self.filter
    find_prices(DECIMAL_PRICE_REGEX, max_words: 3)
    end_word_with_space = ->(term) { term.text += ' ' }

    find_prices(
      HUNGARIAN_PRICE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2
    )

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
        term = PriceTerm.new(
          regex: regex,
          after_each_word: after_each_word,
          max_words: max_words
        )
        last_word = nil

        Word.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = PriceTerm.new(
              regex: regex,
              after_each_word: after_each_word,
              max_words: max_words
            )
          end
          term.add_word(word)

          last_word = word

          term.save if term.valid?
        end
      end
  end
end
