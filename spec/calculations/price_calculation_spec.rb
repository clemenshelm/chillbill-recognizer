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

  it 'takes the right amount if there is no VAT' do
    words = [
      double(text: '1.185,00', bounding_box: double(x: 2199, y: 1996, width: 151, height: 33)),
      double(text: '15,41', bounding_box: double(x: 2768, y: 1995, width: 91, height: 35))
    ]

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('15.41')
    expect(prices.vat_amount).to eq 0
  end
end
