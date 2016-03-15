require 'ostruct'
require 'bigdecimal'
require_relative '../word_list'

class PriceDetector
  class PriceTerm
    attr_reader :words

    def initialize
      @words = []
    end

    def text
      @words.map(&:text).join
    end

    def bounding_box
      # This is definitely not correct,
      # but it's sufficient for now.
      @words.first.bounding_box
    end

    def to_d
      BigDecimal.new(text.sub('.', '').sub(',', '.'))
    end
  end

  def self.filter(tesseract_words)
    linked_words = WordList.new(tesseract_words)
    number_words = linked_words.select { |word| word.text =~ /^[\d,\.]+$/ }

    # No compound numbers
    possible_prices = number_words.select { |word| !(word.next && word.next.text =~ /^\d/) || word.text =~ /\d+[,\.]/ }
    prices = possible_prices.map do |word|
      extract_price(word.self_and_following)
    end

    prices.compact
  end

  private

  def self.extract_price(words)
    term = PriceTerm.new
    # for cases like "45", ",", "00"
    words.take(3).each do |word|
      term.words << word
      return term if term.text =~ /^\d{1,3}(\.\d{3})?+[,\.]\d{1,3}$/
    end

    return nil
  end
end
