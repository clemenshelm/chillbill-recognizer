# frozen_string_literal: true
require_relative '../models/relative_date_term'

class RelativeDateDetector
  RELATIVE_WORDS = /(prompt|Fällig bei Erhalt|Fällig nach Erhalt)/

  def self.filter
    end_word_with_space = ->(term) { term.text += ' ' }
    find_relative_words(RELATIVE_WORDS,
    after_each_word: end_word_with_space
    )

    RelativeDateTerm.dataset
  end

  class << self
    private

      def find_relative_words(regex, after_each_word: nil)
        term = RelativeDateTerm.new(
          regex: regex, after_each_word: after_each_word, max_words: 3
        )
        last_word = nil

        Word.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = RelativeDateTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 3
            )
          end

          term.add_word(word)

          last_word = word

          term.save if term.valid?
        end
      end
  end
end
