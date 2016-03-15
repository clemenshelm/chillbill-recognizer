
require 'sequel'

# TODO unit test
class DateTerm < Sequel::Model
  def initialize
    super
    self.text = ''
  end

  def add_word(word)
    self.text += word.text
    self.left = word.left
    self.top = word.top
    self.right = word.right
    self.bottom = word.bottom
  end
end
