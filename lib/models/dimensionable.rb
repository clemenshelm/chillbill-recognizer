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
      find { |previous| previous.right < current.left }
    end

    def right_after(current)
      all.find do |following|
        (following.left > current.right) &&
          (following.left - current.right) < (following.height * 10) &&
          following.bottom == current.bottom
      end

      all.find do |following|
        (following.left > current.right) &&
          (following.left - current.right) < (following.height * 10.145) &&
          ((following.bottom <= (current.bottom * 1.02)) &&
          ((current.bottom * 0.95) <= following.bottom))
      end
    end
  end
end
