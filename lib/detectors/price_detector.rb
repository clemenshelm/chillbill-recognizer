require 'ostruct'
require 'bigdecimal'
require_relative '../models/price_term'

class PriceDetector
  DECIMAL_PRICE_REGEX = /(?:^|[^\.\d])(€?\d{1,4}(?:\.\d{3})?+[,\.](?:\d{1,3}|-))(?:[^\.\d]|$)/
  WRITTEN_PRICE_REGEX = /(\d+ Euro)/
  SHORT_PRICE_REGEX = /(\d+€)/

  def self.filter
    find_prices(DECIMAL_PRICE_REGEX)

    end_word_with_space = -> (term) { term.text += ' ' }
    find_prices(WRITTEN_PRICE_REGEX, after_each_word: end_word_with_space)

    find_prices(SHORT_PRICE_REGEX)

    PriceTerm.dataset
  end

  private

  def self.find_prices(regex, after_each_word: nil)
    term = PriceTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    Word.each do |word|
      if term.exists? || (last_word && !word.follows(last_word))
        term = PriceTerm.new(regex: regex, after_each_word: after_each_word)
      end
      term.add_word(word)

      last_word = word

      if term.valid?
        term.save
      end
    end
  end
end
