# frozen_string_literal: true
class CurrencyCalculation
  def iso
    return nil if CurrencyTerm.empty?
    currency_term = find_most_accurate_currency
    currency_term&.to_iso
  end

  def find_most_accurate_currency
    return nil if PriceTerm.empty?
    most_accurate_currency_term = CurrencyTerm.below(PriceTerm.first)
    most_accurate_currency_term ||= CurrencyTerm.right_after(PriceTerm.first)
    most_accurate_currency_term || CurrencyTerm.first
  end
end
