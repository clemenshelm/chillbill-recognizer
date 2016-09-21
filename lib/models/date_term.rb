require 'sequel'
require_relative './term_builder'
require_relative '../detectors/date_detector'

# TODO unit test
class DateTerm < Sequel::Model
  attr_reader :regex

  def initialize(attrs)
    @regex = attrs.delete(:regex)
    @term_builder = TermBuilder.new(
      regex: @regex,
      after_each_word: attrs.delete(:after_each_word)
    )
    super
  end

  def add_word(word)
    @term_builder.add_word(word)

    self.text = @term_builder.extract_text
    self.first_word_id = @term_builder.words.first.id
    self.left = word.left
    self.top = word.top
    self.right = word.right
    self.bottom = word.bottom
  end

  def valid?
    @term_builder.valid?
  end

  def to_datetime
    case text
    when /\d+\.\d+\.\d{4}/
      DateTime.parse(text)
    when DateDetector::FULL_GERMAN_DATE_REGEX
      date_text = text.gsub(/März|Dezember/,
        'März' => 'March',
        'Dezember' => 'December'
      )
      DateTime.strptime(date_text, '%d. %B %Y')
    when DateDetector::FULL_ENGLISH_DATE_REGEX
      DateTime.strptime(text, '%d %B %Y')
    when DateDetector::SHORT_PERIOD_DATE_REGEX
      DateTime.strptime(text, '%d.%m.%y')
    when DateDetector::SHORT_SLASH_DATE_REGEX
      DateTime.strptime(text, '%d/%m/%y')
    when DateDetector::ISO_DATE_REGEX
      DateTime.strptime(text, '%y-%m-%d')
    when DateDetector::ENGLISH_COMMA_DATE_REGEX
      DateTime.strptime(text, '%b %d, %Y')
    end
  end

end
