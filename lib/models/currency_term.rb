# frozen_string_literal: true
require 'sequel'
require_relative './term_builder'
require_relative '../detectors/currency_detector'
require_relative './dimensionable'

class CurrencyTerm < Sequel::Model
  include Dimensionable

  def initialize(attrs)
    @term_builder = TermBuilder.new(
      regex: attrs.delete(:regex),
      after_each_word: attrs.delete(:after_each_word)
    )
    super
  end

  def add_word(word)
    @term_builder.add_word(word)
    self.text = @term_builder.extract_text
    self.left = word.left
    self.top = word.top
    self.right = word.right
    self.bottom = word.bottom
  end

  def valid?
    @term_builder.valid?
  end

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
