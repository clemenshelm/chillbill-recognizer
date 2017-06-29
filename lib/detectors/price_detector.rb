require 'ostruct'
require 'bigdecimal'
require_relative '../models/price_term'

class PriceDetector
  PRICE_REGEX = /(-?[1-9]{1}\d{0,3}|0)([\.,]\d{3})?[,\.](\d{2}|-)/
  PREFIX_CURRENCY_REGEX = /(€|EUR)/
  ALLOWED_PREFIX_REGEX = /(?:^|[^\d,A-Z\.])/
  DECIMAL_PRICE_REGEX =
    /#{ALLOWED_PREFIX_REGEX}(#{PREFIX_CURRENCY_REGEX}?#{PRICE_REGEX})$/
  WRITTEN_PRICE_REGEX = /(\d+ Euro)/
  SHORT_PRICE_REGEX = /(\d+€)/
  HUNGARIAN_PRICE_REGEX = /^(\d{2} \d{3}\s)$/

  def self.filter_out_quantity_column
    quantity = Word.first(text: 'Menge')
    PriceTerm.where { right <= quantity.right }.destroy if quantity
  end

  def self.filter
    find_prices(DECIMAL_PRICE_REGEX, max_words: 3)
    filter_out_quantity_column

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
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
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
