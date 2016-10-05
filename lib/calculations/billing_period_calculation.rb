
class BillingPeriodCalculation
  def initialize(words)
    @words = words
  end

  def billing_period
    return nil if @words.empty?
    @words.first.to_isoperiod
  end
end
