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

  def self_and_following
    selfid = id
    Word.where { id >= selfid }
  end

  def follows(previous_word)
    max_space_width = previous_word.height
    # logger.debug "#{text}:: first: #{previous_word.right} =>
    # space: #{max_space_width} => last: #{previous_word.left}"
    previous_word.right + max_space_width >= left
  end
end
