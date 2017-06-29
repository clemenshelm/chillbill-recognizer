# frozen_string_literal: true
require_relative '../detectors/date_detector'
require_relative '../models/date_term'
require_relative '../models/dimensionable'
require_relative '../calculations/relative_date_calculation'

class DateCalculation
  def invoice_date
    return nil if DateTerm.empty?
    invoice_date = find_standalone_dates.first || find_labeled_invoice_date ||
                   BillingPeriodTerm.first.to
    invoice_date.to_datetime
  end

  def find_standalone_dates
    DateTerm.all.select do |term|
      term.started_periods.empty? && term.ended_periods.empty?
    end
  end

  def find_labeled_invoice_date
    return nil if InvoiceDateLabelTerm.empty?
    DateTerm.right_after(InvoiceDateLabelTerm.first)
  end

  def due_date
    return nil if DueDateLabelTerm.empty?
    due_date_term = DateTerm.right_after(DueDateLabelTerm.first)
    due_date_term ||= DateTerm.below(DueDateLabelTerm.first)
    due_date = due_date_term&.to_datetime

    due_date || begin
      date_relative_to = invoice_date
      RelativeDateCalculation.new.relative_date(date_relative_to)
    end
  end
end
