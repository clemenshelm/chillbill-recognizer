# frozen_string_literal: true
require_relative '../detectors/date_detector'
require_relative '../models/date_term'
require_relative '../models/dimensionable'

class DateCalculation
  def initialize(words)
    @words = words
  end

  def invoice_date
    return nil if @words.empty?
    standalone_dates = @words.all.select do |term|
      term.started_periods.empty? && term.ended_periods.empty?
    end

    standalone_dates.first.to_datetime
  end

  def due_date
    return nil if @words.empty?

    # Find due date label
    due_word = Word.where(text: %w(Due Zahlungstermin Zahlungsziel:))

    return nil unless due_word.any?
    due_date_label = Word.right_after(due_word.first)
    date_after_label = if due_date_label.nil?
                          DateTerm.right_after(due_word.first)
                       elsif due_date_label.text == "Date:"
                          DateTerm.right_after(due_date_label)
                       end
                       
    date_after_label.to_datetime
  end
end
