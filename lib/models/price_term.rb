require 'sequel'

# TODO unit test
class PriceTerm < Sequel::Model
  def initialize(*args)
    super
    self.text ||= ''
  end

  def add_word(word)
    self.text += word.text
    self.left = word.left
    self.top = word.top
    self.right = word.right
    self.bottom = word.bottom
  end

  def width
    right - left
  end

  def height
    bottom - top
  end

  def to_d
    # remove thousand separator, but keep comma
    dec_text = text.gsub(/(\d+)\.(.{3,})/, '\1\2')
    # Replace commas with periods
    dec_text.sub!(',', '.')
    BigDecimal.new(dec_text)
  end
end
