require_relative '../detectors/vat_number_detector'

class VatNumberCalculation

  def initialize(words)
    @words = words
  end

  def vat_number
    return nil if @words.empty?
    @words.to_s
  end

  # Can implement for 2nd VAT ID number here

end
