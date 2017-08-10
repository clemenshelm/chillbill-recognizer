# frozen_string_literal: true
require 'sequel'
require_relative './term'
require_relative './dimensionable'

# TODO: unit test
class PriceTerm < Sequel::Model
  include Term
  include Dimensionable

  def valid?
    super && Word.right_after(self)&.text != 'kg' && Word.right_below(self)&.text != 'kg'
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
