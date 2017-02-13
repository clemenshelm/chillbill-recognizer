# frozen_string_literal: true
class CurrencyCalculation
  def iso
    return nil if CurrencyTerm.empty?
    currency_term = find_most_accurate_currency
    currency_term.to_iso unless currency_term.nil?
  end

  def find_most_accurate_currency
    most_accurate_currency_term = CurrencyTerm.right_after(PriceTerm.first)
    most_accurate_currency_term ||= find_most_counted_currency_term
    most_accurate_currency_term || CurrencyTerm.first
  end

  def find_most_counted_currency_term
    CurrencyTerm.all
                .group_by(&:to_iso)
                .max_by { |_, currencies| currencies.size }
                .last.first
  end
end
