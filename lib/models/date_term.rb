require 'sequel'
require_relative './term_builder'

# TODO unit test
class DateTerm < Sequel::Model
  def initialize(attrs)
    @term_builder = TermBuilder.new(
      regex: attrs.delete(:regex),
      after_each_word: attrs.delete(:after_each_word)
    )
    super
  end

  def before_create
    @term_builder.pack!
    self.text = @term_builder.text
    self.first_word_id = @term_builder.words.first.id
  end

  def add_word(word)
    @term_builder.add_word(word)

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
    end
  end

end
