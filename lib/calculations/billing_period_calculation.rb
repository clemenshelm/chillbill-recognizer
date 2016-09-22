require_relative '../detectors/date_detector'
require_relative '../models/billing_period_term'
require_relative '../models/word'

class BillingPeriodCalculation
  def initialize(words)
    @words = words
  end

  def billing_period
    return nil if @words.empty?
    @words.first.to_s
  end
end
