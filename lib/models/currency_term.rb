# frozen_string_literal: true
require 'sequel'
require_relative './term'

class CurrencyTerm < Sequel::Model
  include Term

  def to_iso
    case text
    when *CurrencyDetector::EUR_SYMBOLS
      'EUR'
    when *CurrencyDetector::USD_SYMBOLS
      'USD'
    when *CurrencyDetector::HKD_SYMBOLS
      'HKD'
    when *CurrencyDetector::CHF_SYMBOLS
      'CHF'
    when *CurrencyDetector::CNY_SYMBOLS
      'CNY'
    when *CurrencyDetector::SEK_SYMBOLS
      'SEK'
    when *CurrencyDetector::GBP_SYMBOLS
      'GBP'
    when *CurrencyDetector::HUF_SYMBOLS
      'HUF'
    when *CurrencyDetector::HRK_SYMBOLS
      'HRK'
    end
  end
end
