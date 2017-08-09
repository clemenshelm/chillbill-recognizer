# frozen_string_literal: true
require_relative '../logging'

class TermBuilder
  include Logging
  attr_reader :words
  attr_accessor :text

  def initialize(regex:, after_each_word:, term_class:, max_words: nil)
    @regex = regex
    @after_each_word = after_each_word
    @max_words = max_words || Float::INFINITY
    @term_class = term_class
    @words = []
    @text = ''
  end

  def add_word(word)
    @words.shift until @words.length < @max_words
    @words << word
    @text = ''
    @words.each do |w|
      @text += w.text
      @after_each_word&.call(self)
    end

    matching_groups = text.scan(@regex).first
    # logger.debug "text: #{@text}"
    # logger.debug "groups: #{matching_groups.inspect}"

    @text = Array(matching_groups).first if matching_groups
    @text.strip!
  end

  def valid?
    @text =~ @regex
  end

  def valid_subterm
    (1..@words.length).each do |numwords|
      available_words = @words[-numwords..-1]
      term = @term_class.new(
        regex: @regex, after_each_word: @after_each_word, max_words: @max_words
      )

      available_words.each do |word|
        term.add_word(word)

        return term if term.valid?
      end
    end
    nil
  end
end
