require_relative '../../lib/calculations/price_calculation'

describe PriceCalculation do
  it 'calculates the sub total and the VAT total' do
    words = %w(14.49 2.69 8.19 46.85 0.0 18.79 28.06 20.0 7.81 39.04 100.0).
      map { |text| double(text: text)  }

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('39.04')
    expect(prices.vat_amount).to eq BigDecimal('7.81')
  end

  it 'calculates the sub total and the VAT total for a different bill' do
    words = %w(1.0, 5.19, 7.78, 6.48, 1.3).map { |text| double(text: text) }

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('6.48')
    expect(prices.vat_amount).to eq BigDecimal('1.3')
  end
end
