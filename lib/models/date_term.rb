# frozen_string_literal: true
require 'sequel'
require_relative './term_builder'
require_relative '../detectors/date_detector'
require_relative '../boot'
require_relative './dimensionable'

# TODO: unit test
class DateTerm < Sequel::Model
  include Dimensionable
  # Loading it here resolves issues with the circular dependency
  require_relative './billing_period_term'
  one_to_many :started_periods, class: BillingPeriodTerm, key: :from_id
  one_to_many :ended_periods, class: BillingPeriodTerm, key: :to_id

  def initialize(attrs)
    @term_builder = TermBuilder.new(
      regex: attrs.delete(:regex),
      after_each_word: attrs.delete(:after_each_word),
      max_words: attrs.delete(:max_words)
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
                            'Dezember' => 'December')
      DateTime.strptime(date_text, '%d. %B %Y')
    when DateDetector::FULL_ENGLISH_DATE_REGEX
      DateTime.strptime(text, '%d %B %Y')
    when DateDetector::SHORT_PERIOD_DATE_REGEX
      DateTime.strptime(text, '%d.%m.%y')
    when DateDetector::SHORT_SLASH_DATE_REGEX
      DateTime.strptime(text, '%d/%m/%y')
    when DateDetector::LONG_SLASH_DATE_REGEX
      DateTime.strptime(text, '%d/%m/%Y')
    when DateDetector::LONG_HUNGARIAN_DATE_REGEX
      DateTime.strptime(text, '%Y.%m.%d')
    when DateDetector::LONG_HYPHEN_DATE_REGEX
      DateTime.strptime(text, '%d-%m-%Y')
    end
  end
end
