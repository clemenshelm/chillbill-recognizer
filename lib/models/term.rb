# frozen_string_literal: true
require_relative './term_builder'

module Term
  def initialize(attrs)
    @term_builder = TermBuilder.new(
      regex: attrs.delete(:regex),
      after_each_word: attrs.delete(:after_each_word),
      max_words: attrs.delete(:max_words),
      term_class: self.class
    )
    super
  end

  def add_word(word)
    @term_builder.add_word(word)

    self.text = @term_builder.text
    self.left = @term_builder.words.map(&:left).min
    self.top = @term_builder.words.map(&:top).min
    self.right = @term_builder.words.map(&:right).max
    self.bottom = @term_builder.words.map(&:bottom).max
  end

  def valid?
    @term_builder.valid?
  end

  def valid_subterm
    @term_builder.valid_subterm
  end

  def to_s
    text
  end
end
