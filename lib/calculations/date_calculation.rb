# frozen_string_literal: true
require_relative '../detectors/date_detector'
require_relative '../models/date_term'
require_relative '../models/dimensionable'
require_relative '../calculations/relative_date_calculation'

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

  def due_date(invoice_date = nil)
    return nil if DueDateLabelTerm.empty?
    due_date = DateTerm.right_after(DueDateLabelTerm.first)
    if due_date
      due_date.to_datetime
    else
      RelativeDateCalculation.new(
        RelativeDateTerm.dataset
      ).relative_date(invoice_date)
    end
  end
end
