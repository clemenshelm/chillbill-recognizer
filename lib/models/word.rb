# frozen_string_literal: true
require 'sequel'
require_relative './dimensionable'
require_relative '../logging'

# TODO: unit test
class Word < Sequel::Model
  include Dimensionable
  include Logging

  def next
    Word[id + 1]
  end

  def follows(previous_word)
    max_space_width = previous_word.height * 1.79
    # logger.debug "#{text}:: first: #{previous_word.right} =>
    # space: #{max_space_width} => last: #{previous_word.left}"
    previous_word.right + max_space_width >= left
  end

  def self.filter_out_artifacts
    binding.pry
    # Filter out
    where { left == 0 }&.destroy
    where { right > 1 }&.destroy
    where { top == 0 }&.destroy
    where { bottom > 1 }&.destroy
    where(text: [' ', '!', '*', 'ä'])&.destroy
    binding.pry
  end

end
