# frozen_string_literal: true
module Dimensionable
  def width
    right - left
  end

  def height
    bottom - top
  end

  def horizontal_center
    left + (width / 2)
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def right_before(current)
      all.find do |previous|
        previous.right < current.left && on_same_line(current, previous)
      end
    end

    def right_after(current)
      all.find do |following|
        space_width = following.height * BillDimension.bill_ratio
        (following.left > current.right) &&
          (following.left - current.right) < (space_width * 32) &&
          on_same_line(current, following)
      end
    end

    def right_below(current)
      all.find do |lower|
        lower.top < (current.bottom + lower.height) &&
          lower.top > current.bottom && in_same_column(current, lower) &&
          lower != current
      end
    end

    def right_above(current)
      everything_above = all.select do |above|
        current.top > above.bottom && in_same_column(current, above) &&
          above != current
      end
      everything_above.last
    end

    def match_two_words_after(current, regex1, regex2)
      first_word = right_after(current)

      if first_word && first_word.text.match(regex1)
        second_word = right_after(first_word)
        second_word && second_word.text.match(regex2)
      else
        false
      end
    end

    def bottom_most(current)
      everything_below = all.select do |lower|
        in_same_column(current, lower) && current != lower
      end
      everything_below.last
    end

    private

    def on_same_line(word1, word2)
      word1.bottom > word2.top && word2.bottom > word1.top
    end

    def in_same_column(word1, word2)
      word2.horizontal_center > word1.left &&
        word2.horizontal_center < word1.right
    end
  end
end
