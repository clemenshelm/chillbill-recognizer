# frozen_string_literal: true
require_relative '../models/date_term'
require_relative '../models/dimensionable'

class DueDateCalculation
  def initialize(words)
    @words = words
  end

  def due_date
    return nil if @words.empty?

    # Find due date label
    due_word = Word.where(text: %w(Due Zahlungstermin Zahlungsziel:))

    return nil unless due_word.any?
    due_date_label = Word.right_after(due_word.first)
    date_after_label = if due_date_label.text == %w(due)
                         DateTerm.right_after(due_date_label)
                       else
                         DateTerm.right_after(due_word.first)
                       end
    date_after_label.to_datetime
  end
end
