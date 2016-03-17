
require 'sequel'

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
      date_text = text.gsub(/März/, 'March')
      DateTime.strptime(date_text, '%d. %B %Y')
    when DateDetector::FULL_ENGLISH_DATE_REGEX
      DateTime.strptime(text, '%d %B %Y')
    when DateDetector::SHORT_PERIOD_DATE_REGEX
      DateTime.strptime(text, '%d.%m.%y')
    when DateDetector::SHORT_SLASH_DATE_REGEX
      DateTime.strptime(text, '%d/%m/%y')
    end
  end

  class TermBuilder
    attr_reader :words
    attr_accessor :text

    def initialize(regex:, after_each_word:)
      @regex = regex
      @after_each_word = after_each_word
      @words = []
      @text = ''
    end

    def add_word(word)
      @words << word
      @text += word.text

      @after_each_word.call(self) if @after_each_word

      matching_text = text.scan(@regex).first

      if matching_text
        @text = matching_text
      end
    end

    def valid?
      @text =~ @regex
    end

    def pack!
      catch(:done) do
        (1..@words.length).each do |numwords|
          available_words = @words[-numwords..-1]
          builder = TermBuilder.new(regex: @regex, after_each_word: @after_each_word)

          available_words.each do |word|
            builder.add_word(word)

            if builder.valid?
              @words = builder.words
              throw :done
            end
          end
        end
    end
    end
  end
end
