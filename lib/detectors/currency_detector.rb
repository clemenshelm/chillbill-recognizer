# frozen_string_literal: true
require_relative '../models/currency_term'

class CurrencyDetector
  EUR_SYMBOLS = %w(EUR € EURO)
  USD_SYMBOLS = %w(USD $)
  HKD_SYMBOLS = %w(HKD $)
  CHF_SYMBOLS = %w(CHF)
  CNY_SYMBOLS = %w(CNY)
  SEK_SYMBOLS = %w(SEK)
  GBP_SYMBOLS = %w(GBP £)
  HUF_SYMBOLS = %w(HUF Ft.)
  HRK_SYMBOLS = %w(HRK)
  ALL_SYMBOLS = EUR_SYMBOLS + USD_SYMBOLS + HKD_SYMBOLS +
    CHF_SYMBOLS + CNY_SYMBOLS + SEK_SYMBOLS + GBP_SYMBOLS +
    HUF_SYMBOLS + HRK_SYMBOLS

  def self.filter
    currencies_regex = /#{Regexp.quote(ALL_SYMBOLS.join('|'))}/
    find_currencies(currencies_regex)

    CurrencyTerm.dataset
  end

  def self.find_currencies(regex, after_each_word: nil)
    private
    term = CurrencyTerm.new(regex: regex, after_each_word: after_each_word)

    Word.each do |word|
      if term.exists?
        term = CurrencyTerm.new(regex: regex, after_each_word: after_each_word)
      end

      term.add_word(word)

      term.save if term.valid?
    end
  end
end
