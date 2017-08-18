# frozen_string_literal: true
require 'sequel'
require_relative './term'
require_relative '../detectors/date_detector'
require_relative '../boot'
require_relative './dimensionable'

# TODO: unit test
class DateTerm < Sequel::Model
  include Term
  include Dimensionable

  # Loading it here resolves issues with the circular dependency
  require_relative './billing_period_term'
  one_to_many :started_periods, class: BillingPeriodTerm, key: :from_id
  one_to_many :ended_periods, class: BillingPeriodTerm, key: :to_id

  def words
    @term_builder.words.dup
  end

  def add_word(word)
    super
    self.first_word_id = @term_builder.words.first.id
  end

  def valid?
    to_datetime
    super
  rescue ArgumentError
    false
  rescue RangeError
    false
  end

  def to_datetime
    case text
    when /^\d{2}\.\d{2}\.\d{4}/
      DateTime.parse(text)
    when DateDetector::FULL_GERMAN_DATE_REGEX
      date_text = text.gsub(/Februar|März|Oktober|Dezember/,
                            'Februar' => 'February',
                            'März' => 'March',
                            'Oktober' => 'October',
                            'Dezember' => 'December')
      DateTime.strptime(date_text, '%d. %B %Y')
    when DateDetector::SHORT_ENGLISH_DATE_REGEX
      date_text = text.gsub(/Oct/,
                            'Oct' => 'October')
      DateTime.strptime(date_text, '%d-%B-%Y')
    when DateDetector::SHORT_ENGLISH_DATE_WITH_SPACE_REGEX
      date_text = text.gsub(/Jul/,
                            'Jul' => 'July')
      DateTime.strptime(date_text, '%d %B %Y')
    when DateDetector::FULL_ENGLISH_DATE_REGEX
      DateTime.strptime(text, '%d %B %Y')
    when DateDetector::FULL_ENGLISH_COMMA_DATE_REGEX
      DateTime.strptime(text, '%B %d, %Y')
    when DateDetector::SHORT_PERIOD_DATE_REGEX
      DateTime.strptime(text, '%d.%m.%y')
    when DateDetector::LONG_YEAR_SLASH_REGEX
      DateTime.strptime(text, '%Y/%m/%d')
    when DateDetector::SHORT_SLASH_DATE_REGEX
      DateTime.strptime(text, '%d/%m/%y')
    when DateDetector::LONG_SLASH_DATE_REGEX
      DateTime.strptime(text, '%d/%m/%Y')
    when DateDetector::AMERICAN_LONG_SLASH_DATE_REGEX
      DateTime.strptime(text, '%m/%d/%Y')
    when DateDetector::LONG_HUNGARIAN_DATE_REGEX
      DateTime.strptime(text, '%Y.%m.%d')
    when DateDetector::LONG_HYPHEN_DATE_REGEX
      DateTime.strptime(text, '%d-%m-%Y')
    end
  end
end
