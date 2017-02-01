# frozen_string_literal: true
require_relative '../detectors/vat_number_detector'

class VatNumberCalculation
  def initialize(customer_vat_number:)
    @customer_vat_number = customer_vat_number
  end

  def vat_number
    return nil if VatNumberTerm.empty?
    VatNumberTerm.exclude(text: @customer_vat_number).first.to_s
  end
end
