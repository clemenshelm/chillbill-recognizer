require 'ostruct'

class PriceDetector
  class Word
    attr_accessor :next

    def initialize(tesseract_word)
      @tesseract_word = tesseract_word
    end

    def self.link(tesseract_words)
      words = tesseract_words.map do |tess_word|
        Word.new(tess_word)
      end
      words.each_cons(2) do |prev, nxt|
        prev.next = nxt
      end

      words
    end

    def text
      @tesseract_word.text.encode(invalid: :replace)
    end

    def bounding_box
      @tesseract_word.bounding_box
    end

    def self_and_following
      klon = self.clone

      def klon.each
        word = self
        while word
          yield word
          word = word.next
        end
      end

      klon.to_enum
    end
  end

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
      BigDecimal.new(text.sub(',', '.'))
    end
  end

  def self.filter(tesseract_words)
    linked_words = Word.link(tesseract_words)
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
      return term if term.text =~ /^\d+[,\.]\d{1,3}$/
    end

    return nil
  end
end
