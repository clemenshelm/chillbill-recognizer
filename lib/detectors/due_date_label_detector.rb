# frozen_string_literal: true
require_relative '../models/due_date_label_term'

class DueDateLabelDetector
  DUE_DATE_LABELS =
    /(?:^|(?<= ))(Zahlungstermin|Due Date:|Zahlungsziel:)(?:(?= )|$)/

  def self.filter
    end_word_with_space = -> (term) { term.text += ' ' }
    find_due_date_labels(DUE_DATE_LABELS, after_each_word: end_word_with_space)
    DueDateLabelTerm.dataset
  end

  def self.find_due_date_labels(regex, after_each_word: nil)
    private
    term = DueDateLabelTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    Word.each do |word|
      if term.exists? || (last_word && !word.follows(last_word))
        term = DueDateLabelTerm.new(
          regex: regex, after_each_word: after_each_word
        )
      end

      term.add_word(word)

      last_word = word

      term.save if term.valid?
    end
  end
end

# ONE_WORD_LABELS =
#   /(?:^|(?<= ))(Zahlungstermin|Zahlungsziel:)(?:(?= )|$)/
# MULTIPLE_WORD_LABELS = /(Due Date:)/
#
# def self.filter
#   find_due_date_labels(DUE_DATE_LABELS)
#   find_due_date_labels(DUE_DATE_LABELS, after_each_word: end_word_with_space)
