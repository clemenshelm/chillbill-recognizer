# frozen_string_literal: true
require 'sequel'
require_relative './term'
require_relative './dimensionable'

# TODO: unit test
class PriceTerm < Sequel::Model
  include Term
  include Dimensionable

  def valid?
    super && !pass_unit_check
    # binding.pry
  end

  def pass_unit_check
    Word::UNITS.include?(Word.right_after(self)&.text) ||
      Word::UNITS.include?(Word.right_above(self)&.text)
  end

  def to_d
    # remove thousand separator, but keep comma
    dec_text = text.gsub(/(\d+)\.(.{3,})/, '\1\2')
    # Replace commas with periods
    dec_text.sub!(',', '.')
    # If the string cotains two periods then replace the first one
    dec_text.sub!('.', '') if dec_text.count('.') == 2
    # Replace space
    dec_text.sub!(' ', '')
    # Remove currency symbols
    dec_text.sub!('€', '')
    BigDecimal.new(dec_text)
  end

  def to_h
    {
      'text' => text,
      'price' => (to_d * 100).round.to_i,
      'left' => left,
      'right' => right,
      'top' => top,
      'bottom' => bottom
    }
  end
end
