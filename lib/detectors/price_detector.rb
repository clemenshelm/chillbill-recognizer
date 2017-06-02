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

  def self.filter_out_unnecessary_numbers
    Word.where(:text => 'kg').all.each do |term|
      Word.where(id: term.previous.id)
      .delete if term != nil && term.id > 0
    end
  end

  def self.filter
    filter_out_unnecessary_numbers

    find_prices(Word.all,
                DECIMAL_PRICE_REGEX,
                max_words: 3)

    end_word_with_space = ->(term) { term.text += ' ' }

    find_prices(
      Word.all,
      HUNGARIAN_PRICE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2
    )

    find_prices(
      Word.all,
      WRITTEN_PRICE_REGEX,
      after_each_word: end_word_with_space,
      max_words: 2
    )

    find_prices(Word.all,SHORT_PRICE_REGEX, max_words: 1)
    PriceTerm.dataset
  end

  class << self
    private

      def find_prices(words, regex, after_each_word: nil, max_words: nil)
        term = initialize_new_term(regex, after_each_word, max_words)
        last_word = nil

        words.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = initialize_new_term(regex, after_each_word, max_words)
          end
          term.add_word(word)
          last_word = word

          term.save if term.valid?
        end
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
