# frozen_string_literal: true
require_relative '../models/relative_date_term'

class RelativeDateDetector
  SAME_DAY_TERMS = ['prompt', 'Fällig bei Erhalt', 'Fällig nach Erhalt'].freeze
  ALL_REL_WORDS = SAME_DAY_TERMS

  def self.filter
    relative_regex = /#{ALL_REL_WORDS.map { |s| Regexp.quote(s) }.join('|')}/
    end_word_with_space = ->(term) { term.text += ' ' }
    find_relative_words(relative_regex,
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
