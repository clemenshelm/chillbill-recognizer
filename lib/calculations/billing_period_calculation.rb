require_relative '../models/date_term'

class BillingPeriodCalculation
  def initialize(words)
    @words = words
  end

  def billing_period
    return nil if @words.empty?
    { from: @words.first.from.to_datetime,
      to: @words.first.to.to_datetime
    }
  end
end
