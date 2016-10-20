# frozen_string_literal: true
require_relative '../models/currency_term'

class CurrencyDetector
  EUR_CODE_REGEX = /EUR|€/
  USD_CODE_REGEX = /USD|\$/
  HKD_CODE_REGEX = /HKD|\$/
  CHF_CODE_REGEX = /CHF/
  CNY_CODE_REGEX = /CNY/
  SEK_CODE_REGEX = /SEK/
  GBP_CODE_REGEX = /GBP|£/
  HUF_CODE_REGEX = /HUF/
  HRK_CODE_REGEX = /HRK/

  def self.filter
    find_currencies(EUR_CODE_REGEX)
    find_currencies(USD_CODE_REGEX)
    find_currencies(CHF_CODE_REGEX)
    find_currencies(CNY_CODE_REGEX)
    find_currencies(SEK_CODE_REGEX)
    find_currencies(GBP_CODE_REGEX)
    find_currencies(HUF_CODE_REGEX)
    find_currencies(HRK_CODE_REGEX)

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
