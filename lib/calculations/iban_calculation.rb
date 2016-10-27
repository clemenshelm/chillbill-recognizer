# frozen_string_literal: true
require_relative '../detectors/iban_detector'

class IbanCalculation
  def initialize(iban_terms)
    @iban_terms = iban_terms
  end

  def iban
    return nil if @iban_terms.empty?
    @iban_terms.first.to_s
  end
end
