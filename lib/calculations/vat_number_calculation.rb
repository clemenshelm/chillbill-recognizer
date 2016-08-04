require_relative '../detectors/vat_number_detector'

class VatNumberCalculation

  def initialize(words, customer_vat_number:)
    @words = words
    @customer_vat_number = customer_vat_number
  end

  def vat_number
    return nil if @words.empty?
    @words.exclude(text: @customer_vat_number).first.to_s
  end
end
