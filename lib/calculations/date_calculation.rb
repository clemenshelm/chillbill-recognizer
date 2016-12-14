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

    invoiceDate = standalone_dates.first || BillingPeriodTerm.first.to
    invoiceDate.to_datetime
  end

  def due_date
    return nil if DueDateLabelTerm.empty?
    due_date = DateTerm.right_after(DueDateLabelTerm.first)
    due_date ||= DateTerm.below(DueDateLabelTerm.first)
    due_date.to_datetime
  end
end
