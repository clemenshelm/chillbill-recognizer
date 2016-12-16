# frozen_string_literal: true
module Dimensionable
  def width
    right - left
  end

  def height
    bottom - top
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
        (following.left > current.right) &&
          (following.left - current.right) < (following.height * 19) &&
          on_same_line(current, following)
      end
    end

    def below(current)
      all.find do |lower|
        lower.right > current.left && lower != current
      end
    end

    private

    def on_same_line(word1, word2)
      word1.bottom > word2.top && word2.bottom > word1.top
    end
  end
end
