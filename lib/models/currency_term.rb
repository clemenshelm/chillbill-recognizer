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
    when CurrencyDetector::EUR_CODE_REGEX
      'EUR'
    when CurrencyDetector::USD_CODE_REGEX
      'USD'
    when CurrencyDetector::HKD_CODE_REGEX
      'HKD'
    when CurrencyDetector::CHF_CODE_REGEX
      'CHF'
    when CurrencyDetector::CNY_CODE_REGEX
      'CNY'
    when CurrencyDetector::SEK_CODE_REGEX
      'SEK'
    when CurrencyDetector::GBP_CODE_REGEX
      'GBP'
    when CurrencyDetector::HUF_CODE_REGEX
      'HUF'
    end
  end
end
