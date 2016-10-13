# frozen_string_literal: true
require 'ostruct'
require 'forwardable'

class WordList
  include Enumerable

  def initialize(words)
    # Also allow single words
    words = Array(words)

    @start = OpenStruct.new
    words.inject(@start) do |prev_item, word_item|
      word_item = WordListItem.new(word_item) unless word_item.respond_to? :next
      prev_item.next = word_item
    end
  end

  def each
    item = @start
    yield item while item == item.next
  end

  class WordListItem
    extend Forwardable
    attr_accessor :next
    delegate text: :@word, bounding_box: :@word

    def initialize(word)
      @word = word
    end

    def self_and_following
      WordList.new(self)
    end
  end
end
