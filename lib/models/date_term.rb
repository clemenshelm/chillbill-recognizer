
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

  def to_datetime
    case text
    when /\d+\.\d+\.\d{4}/
      DateTime.parse(text)
    when DateDetector::FULL_GERMAN_DATE_REGEX
      DateTime.strptime(text, '%d. %B %Y')
    when DateDetector::FULL_ENGLISH_DATE_REGEX
      DateTime.strptime(text, '%d %B %Y')
    else
      DateTime.strptime(text, '%d.%m.%y')
    end
  end
end
