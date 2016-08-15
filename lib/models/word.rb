require 'sequel'
require_relative './dimensionable'
require_relative '../logging'

# TODO unit test
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

  def follows(other_word)
    max_space_width = other_word.height
    # logger.debug "#{text}:: first: #{other_word.right} => space: #{max_space_width} => last: #{other_word.left}"
    other_word.right + max_space_width >= self.left
  end
end
