# frozen_string_literal: true
require 'ostruct'
require 'bigdecimal'
require_relative '../models/price_term'

class PriceDetector
  DECIMAL_PRICE_REGEX =
    /(?:^|[^\d,A-Z])(€?([1-9]{1}\d{0,3}|0)([\.,]\d{3})?[,\.](\d{2}|-))$/
  WRITTEN_PRICE_REGEX = /(\d+ Euro)/
  SHORT_PRICE_REGEX = /(\d+€)/
  HUNGARIAN_PRICE_REGEX = /^[0-9]{2} [0-9]{3}/

  def self.filter_out_unneccesary_decimals

    decimals = []

#    Word.map do |decimal|
#      decimals += decimal if decimal =~ DECIMAL_PRICE_REGEX
#    end


    words = Word.where(:text => 'kg')
    binding.pry
  end

  def self.filter

    reduced_words = filter_out_unneccesary_decimals

    find_prices(
      Word.all,
      DECIMAL_PRICE_REGEX,
      max_words: 3
    )

    end_word_with_space = ->(term) { term.text += ' ' }

    find_prices(
      reduced_words,
      HUNGARIAN_PRICE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2
    )

    find_prices(
      reduced_words,
      WRITTEN_PRICE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2
    )

    find_prices(reduced_words,SHORT_PRICE_REGEX, max_words: 1)

    PriceTerm.dataset
  end

  class << self
    private

      def find_prices(words, regex, after_each_word: nil, max_words: nil)
        affected_words = []
        term = initialize_new_term(regex, after_each_word, max_words)
        last_word = nil

        words.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = initialize_new_term(regex, after_each_word, max_words)
          end
          term.add_word(word)

          last_word = word

          if term.valid?
            term.save
            affected_words += term.words
          end
        end
        affected_words
      end

      def initialize_new_term(regex, after_each_word, max_words)
        PriceTerm.new(
          regex: regex,
          after_each_word: after_each_word,
          max_words: max_words
        )
      end
  end
end
