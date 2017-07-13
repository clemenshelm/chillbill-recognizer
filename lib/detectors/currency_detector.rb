# frozen_string_literal: true
require_relative '../models/currency_term'

class CurrencyDetector
  EUR_SYMBOLS = %w(EUR € Euro).freeze
  USD_SYMBOLS = %w(USD $).freeze
  HKD_SYMBOLS = %w(HKD $).freeze
  CHF_SYMBOLS = %w(CHF).freeze
  CNY_SYMBOLS = %w(CNY).freeze
  SEK_SYMBOLS = %w(SEK).freeze
  GBP_SYMBOLS = %w(GBP £).freeze
  HUF_SYMBOLS = %w(HUF Ft.).freeze
  HRK_SYMBOLS = %w(HRK).freeze
  ALL_SYMBOLS = EUR_SYMBOLS + USD_SYMBOLS + HKD_SYMBOLS +
                CHF_SYMBOLS + CNY_SYMBOLS + SEK_SYMBOLS + GBP_SYMBOLS +
                HUF_SYMBOLS + HRK_SYMBOLS

  def self.filter
    currencies_regex = /#{ALL_SYMBOLS.map { |s| Regexp.quote(s) }.join('|')}/
    find_currencies(currencies_regex)

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
