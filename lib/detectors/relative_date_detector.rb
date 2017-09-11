# frozen_string_literal: true
require_relative '../models/relative_date_term'

class RelativeDateDetector
  SAME_DAY_TERMS = /(prompt|Fällig bei Erhalt|Fällig nach Erhalt)/

  def self.filter
    end_word_with_space = ->(term) { term.text += ' ' }
    find_relative_words(SAME_DAY_TERMS,
                        after_each_word: end_word_with_space)

    RelativeDateTerm.dataset
  end

  class << self
    private

      def find_relative_words(regex, after_each_word: nil)
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = RelativeDateTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 3
            )
          end

          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
