require 'ostruct'
require 'bigdecimal'
require_relative '../models/price_term'

class PriceDetector
  def self.filter
    number_words = Word.all.select { |word| word.text =~ /^[\d,\.]+$/ }

    # No compound numbers
    possible_prices = number_words.select { |word| !(word.next && word.next.text =~ /^\d/) || word.text =~ /\d+[,\.]/ }
    possible_prices.each do |word|
      extract_price(word.self_and_following)
    end

    PriceTerm.dataset
  end

  private

  def self.extract_price(words)
    term = PriceTerm.new
    # for cases like "45", ",", "00"
    words.limit(3).each do |word|
      term.add_word(word)
      term.save and return if term.text =~ /^\d{1,3}(\.\d{3})?+[,\.]\d{1,3}$/
    end
  end
end
