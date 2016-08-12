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

    matching_groups = text.scan(@regex).first
    # puts "text: #{@text}"
    # puts "groups: #{matching_groups.inspect}"

    if matching_groups
      @text = Array(matching_groups).first
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
