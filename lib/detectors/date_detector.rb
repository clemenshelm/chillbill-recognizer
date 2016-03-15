class DateDetector
  SHORT_GERMAN_DATE_REGEX = /^\d+\.\d{2}\.\d+$/
  FULL_GERMAN_DATE_REGEX = /^\d+\. April \d+/

  class DateTerm
    attr_reader :words
    attr_accessor :text

    def initialize
      @words = []
      @text = ''
    end

    def bounding_box
      # This is definitely not correct,
      # but it's sufficient for now.
      @words.first.bounding_box
    end
  end

  def self.filter(tesseract_words)
    linked_words = WordList.new(tesseract_words)

    dates = linked_words.map do |word|
      extract_date(word.self_and_following)
    end

    dates.compact
  end

  private

  def self.extract_date(words)
    extract_short_german_date(words) or extract_long_german_date(words)
  end

  def self.extract_short_german_date(words)
    term = DateTerm.new
    # for cases like "10", "04.2015"
    words.take(2).each do |word|
      word_text = word.text

      # Delete text before first number
      after_first_number = word_text.match(/\d.+$/)
      return nil unless after_first_number
      word_text = after_first_number[0]

      term.words << word
      term.text += word_text
      term.text += '.' if term.text =~ /^\d+$/
      return term if term.text =~ SHORT_GERMAN_DATE_REGEX
    end

    return nil
  end

  def self.extract_long_german_date(words)
    term = DateTerm.new
    # for cases like "23.", "April", "2015"
    term.text = words.take(3).map(&:text).join(' ')
    return term if term.text =~ FULL_GERMAN_DATE_REGEX
  end
end
