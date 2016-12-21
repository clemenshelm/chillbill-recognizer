# frozen_string_literal: true
require_relative '../models/date_term'
require_relative '../models/dimensionable'

class BillingPeriodCalculation
  def initialize(words)
    @words = words
  end

  def billing_period
    return nil if @words.empty?
    billing_period_start = DateTerm.right_after(
      BillingStartLabelTerm.first
    ) unless BillingStartLabelTerm.empty?

    billing_period_end = DateTerm.right_after(
      BillingEndLabelTerm.first
    ) unless BillingEndLabelTerm.empty?
    
    {
      from: billing_period_start || @words.first.from.to_datetime,
      to: billing_period_end || @words.first.to.to_datetime
    }
  end
end
