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

    due_date_label= Word.where(text: %w(Due Date: Zahlungstermin Zahlungsziel:))
    DateTerm.right_after(due_date_label.last).to_datetime
  end
end
