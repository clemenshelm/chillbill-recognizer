# frozen_string_literal: true
require_relative '../logging'

class TermBuilder
  include Logging
  attr_reader :words
  attr_accessor :text

  def initialize(regex:, after_each_word:)
    @regex = regex
    @after_each_word = after_each_word
    @words = []
    @text = ''
  end

  def add_word(word)
    @words << word
    @text += word.text
    @after_each_word&.call(self)

    matching_groups = text.scan(@regex).first
    # logger.debug "text: #{@text}"
    # logger.debug "groups: #{matching_groups.inspect}"

    @text = Array(matching_groups).first if matching_groups
  end

  def valid?
    @text =~ @regex
  end

  def extract_text
    (1..@words.length).each do |numwords|
      available_words = @words[-numwords..-1]
      builder = TermBuilder.new(
        regex: @regex, after_each_word: @after_each_word
      )

      available_words.each do |word|
        builder.add_word(word)

        return builder.text if builder.valid?
      end
    end
  end
end
