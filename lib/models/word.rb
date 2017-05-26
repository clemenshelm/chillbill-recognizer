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

  def previous
    Word[id - 1]
  end

  def follows(previous_word)
    max_space_width = previous_word.height * 1.76
    # logger.debug "#{text}:: first: #{previous_word.right} =>
    # space: #{max_space_width} => last: #{previous_word.left}"
    previous_word.right + max_space_width >= left
  end
end
