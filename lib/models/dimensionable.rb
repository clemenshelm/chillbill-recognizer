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
          (following.left - current.right) < (following.height * 19) &&
          ((following.bottom <= (current.bottom + following.height)) &&
          (following.bottom >= (current.bottom - following.height)))
      end
    end

    def below(current)
      all.find do |lower|
        lower.right > current.left && lower != current
      end
    end
  end
end
