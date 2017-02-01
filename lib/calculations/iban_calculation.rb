# frozen_string_literal: true

class IbanCalculation
  def iban
    return nil if IbanTerm.empty?
    IbanTerm.first.to_s
  end
end
