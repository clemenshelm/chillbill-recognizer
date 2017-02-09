# frozen_string_literal: true
require_relative '../models/due_date_label_term'

class DueDateLabelDetector
  DUE_DATE_LABELS =
    /(Zahlungstermin|Due Date:|Zahlungsziel:|Fällig)/

  def self.filter
    end_word_with_space = ->(term) { term.text += ' ' }
    find_due_date_labels(
      DUE_DATE_LABELS,
      after_each_word: end_word_with_space
    )
    DueDateLabelTerm.dataset
  end

  class << self
    private

      def find_due_date_labels(regex, after_each_word: nil)
        term = DueDateLabelTerm.new(
          regex: regex, after_each_word: after_each_word, max_words: 2
        )
        last_word = nil

        Word.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = DueDateLabelTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 2
            )
          end

          term.add_word(word)

          last_word = word

          term.save if term.valid?
        end
      end
  end
end
