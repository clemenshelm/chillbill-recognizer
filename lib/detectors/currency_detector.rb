# frozen_string_literal: true
require_relative '../models/currency_term'

class CurrencyDetector
  EUR_SYMBOLS = /EUR|€|Euro/
  USD_SYMBOLS = /USD|\$/
  HKD_SYMBOLS = /HKD/
  CHF_SYMBOLS = /CHF/
  CNY_SYMBOLS = /CNY/
  SEK_SYMBOLS = /SEK/
  GBP_SYMBOLS = /GBP|£/
  HUF_SYMBOLS = /HUF|Ft.|Ft/
  HRK_SYMBOLS = /HRK/
  ALL_SYMBOLS = [EUR_SYMBOLS, USD_SYMBOLS, HKD_SYMBOLS,
                 CHF_SYMBOLS, CNY_SYMBOLS, SEK_SYMBOLS, GBP_SYMBOLS,
                 HUF_SYMBOLS, HRK_SYMBOLS].freeze

  def self.filter
    ALL_SYMBOLS.map { |s| find_currencies(s) }
    CurrencyTerm.dataset
  end

  class << self
    private

      def find_currencies(regex)
        term = nil
        term_stale = true

        Word.each do |word|
          term = CurrencyTerm.new(regex: regex, max_words: 1) if term_stale

          term.add_word(word)

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
