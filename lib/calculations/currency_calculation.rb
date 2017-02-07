# frozen_string_literal: true
class CurrencyCalculation
  def iso
    return nil if CurrencyTerm.empty?
    currency_term = find_most_accurate_currency
    currency_term.to_iso
  end

  def find_most_accurate_currency
    return nil if PriceTerm.empty?
    most_accurate_currency_term = find_most_counted_currency_term
    most_accurate_currency_term ||= CurrencyTerm.right_after(PriceTerm.first)
    most_accurate_currency_term || CurrencyTerm.first
  end

  def find_most_counted_currency_term
    return nil if CurrencyTerm.empty?

    currency_occur_hash = CurrencyTerm.all.group_by(&:to_iso)
                                      .map do |currency, occurence|
      { currency: currency, occur: occurence.size }
    end

    most_appeared_currency = currency_occur_hash
                             .max_by { |currency| currency[:occur] }[:currency]

    CurrencyTerm.all.select do |currency|
      return currency if currency.to_iso.equal?(most_appeared_currency)
    end
  end
end
