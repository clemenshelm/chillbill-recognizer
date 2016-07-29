require_relative '../detectors/vatnumber_detector'

class VatNumberCalculation

  def initialize(vat_number)
    @vat_number = vat_number
  end

  def vat_number
    return nil if @vat_number.empty?
    @vat_number.to_s
  end

  # Can implement for 2nd VAT ID number here

end
