require 'sequel'
require_relative './term_builder'

class VatNumberTerm < Sequel::Model
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

  def to_s
    text
  end
end
