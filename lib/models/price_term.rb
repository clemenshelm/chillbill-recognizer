# frozen_string_literal: true
require 'sequel'
require_relative './term_builder'
require_relative './dimensionable'

# TODO: unit test
class PriceTerm < Sequel::Model
  include Dimensionable

  def initialize(attrs)
    @term_builder = TermBuilder.new(
      regex: attrs.delete(:regex),
      after_each_word: attrs.delete(:after_each_word),
      max_words: attrs.delete(:max_words)
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

  def words
    @term_builder.words.dup
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
