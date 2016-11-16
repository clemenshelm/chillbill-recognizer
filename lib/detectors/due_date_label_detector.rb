# frozen_string_literal: true
require_relative '../models/due_date_label_term'

class DueDateLabelDetector
  DUE_DATE_LABELS =
    /(?:^|(?<= ))(Zahlungstermin|DueDate:|Zahlungsziel:)(?:(?= )|$)/

  def self.filter
    find_due_date_labels(DUE_DATE_LABELS)
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
