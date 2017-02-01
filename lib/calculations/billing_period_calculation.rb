# frozen_string_literal: true
require_relative '../models/date_term'
require_relative '../models/dimensionable'

class BillingPeriodCalculation
  def billing_period
    return nil if BillingPeriodTerm.empty?

    {
      from: BillingPeriodTerm.first.from.to_datetime,
      to: BillingPeriodTerm.first.to.to_datetime
    }
  end
end
