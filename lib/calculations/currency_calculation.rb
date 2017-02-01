# frozen_string_literal: true
class CurrencyCalculation
  def iso
    return nil if CurrencyTerm.empty?
    CurrencyTerm.last.to_iso
  end
end
