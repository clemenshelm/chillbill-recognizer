require_relative '../detectors/date_detector'

class DateCalculation
  def initialize(words)
    @words = words
  end

  def invoice_date
    return nil if @words.empty?
    @words.first.to_datetime
  end
end
