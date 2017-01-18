# frozen_string_literal: true
require_relative '../detectors/date_detector'
require_relative '../models/date_term'
require_relative '../models/dimensionable'
require_relative '../calculations/relative_date_calculation'

class DateCalculation
  def invoice_date
    return nil if DateTerm.empty?
    standalone_dates = DateTerm.all.select do |term|
      term.started_periods.empty? && term.ended_periods.empty?
    end
    labeled_invoice_date = DateTerm.right_after(
      InvoiceDateLabelTerm.first
    ) unless InvoiceDateLabelTerm.empty?
    invoice_date = labeled_invoice_date || standalone_dates.first ||
                   BillingPeriodTerm.first.to
    invoice_date.to_datetime
  end

  def due_date
    return nil if DueDateLabelTerm.empty?
    due_date_term = DateTerm.right_after(DueDateLabelTerm.first)
    due_date_term ||= DateTerm.below(DueDateLabelTerm.first)
    due_date = due_date_term&.to_datetime

    due_date || begin
      date_relative_to = invoice_date
      RelativeDateCalculation.new(
        RelativeDateTerm.dataset
      ).relative_date(date_relative_to)
    end
  end
end
