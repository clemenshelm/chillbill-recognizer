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
      find {|previous| previous.right < current.left}
    end

    def right_after(current)
      all.find {|following| (following.left > current.right) && (following.left - current.right) < (following.height * 1)}
    end
  end
end
