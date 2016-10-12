require_relative '../../lib/calculations/price_calculation'

describe PriceCalculation do
  before(:each) do
    Word.dataset.delete
    PriceTerm.dataset.delete
    BillingPeriodTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete
    CurrencyTerm.dataset.delete
  end

  it 'calculates the sub total and the VAT total' do
    %w(14.49 2.69 8.19 46.85 0.0 18.79 28.06 20.0 7.81 39.04 100.0).
      each { |text| PriceTerm.create(text: text)  }

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq BigDecimal('39.04')
    expect(prices.vat_amount).to eq BigDecimal('7.81')
  end

  it 'calculates the sub total and the VAT total for a different bill' do
    %w(1.0 5.19 7.78 6.48 1.3).map { |text| PriceTerm.create(text: text) }

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq BigDecimal('6.48')
    expect(prices.vat_amount).to eq BigDecimal('1.3')
  end

  it 'takes the right amount if there is no VAT' do
    PriceTerm.create(text: '1.185,00', left: 2199, top: 1996, right: 2350, bottom: 2029)
    PriceTerm.create(text: '15,41', left: 2768, top: 1995, right: 2859, bottom: 2030)

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq BigDecimal('15.41')
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the right amount if the VAT is 0' do
    PriceTerm.create(text: '80,00', left: 2320, top: 2033, right: 2430, bottom: 2070)
    PriceTerm.create(text: '80,00', left: 2576, top: 2034, right: 2686, bottom: 2071)
    PriceTerm.create(text: '80,00', left: 2576, top: 2215, right: 2686, bottom: 2253)
    PriceTerm.create(text: '0,00', left: 2300, top: 2305, right: 2386, bottom: 2342)
    PriceTerm.create(text: '0,00', left: 2599, top: 2306, right: 2685, bottom: 2343)
    PriceTerm.create(text: '80,00', left: 2574, top: 2403, right: 2686, bottom: 2443)

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq BigDecimal('80.00')
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the highest right amount if there are multiple' do
    PriceTerm.create(text: "190,00", left: 2706, top: 1559, right: 2824, bottom: 1596)
    PriceTerm.create(text: "80,00", left: 2726, top: 1619, right: 2823, bottom: 1656)
    PriceTerm.create(text: "80,00", left: 2724, top: 1680, right: 2823, bottom: 1717)
    PriceTerm.create(text: "350,00", left: 657, top: 3397, right: 833, bottom: 3450)

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq 350
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the highes net amount and VAT amount if there are many possibilities' do
    PriceTerm.create(text: "14,49", left: 2703, top: 1313, right: 2813, bottom: 1349)
    PriceTerm.create(text: "14,49", left: 2704, top: 1433, right: 2813, bottom: 1469)
    PriceTerm.create(text: "2,69", left: 2724, top: 1556, right: 2812, bottom: 1592)
    PriceTerm.create(text: "8,19", left: 2725, top: 1676, right: 2812, bottom: 1712)
    PriceTerm.create(text: "46,85", left: 2702, top: 1916, right: 2814, bottom: 1955)
    PriceTerm.create(text: "46,85", left: 2701, top: 2037, right: 2812, bottom: 2133)
    PriceTerm.create(text: "0,00", left: 2724, top: 2098, right: 2811, bottom: 2134)
    PriceTerm.create(text: "46,85", left: 2702, top: 2104, right: 2894, bottom: 2293)
    PriceTerm.create(text: "0,00", left: 2724, top: 2279, right: 2812, bottom: 2313)
    PriceTerm.create(text: "46,85", left: 2701, top: 2399, right: 2814, bottom: 2437)
    PriceTerm.create(text: "18,79", left: 2703, top: 2519, right: 2812, bottom: 2555)
    PriceTerm.create(text: "28,06", left: 2701, top: 2580, right: 2812, bottom: 2615)
    PriceTerm.create(text: "28,06", left: 2400, top: 2823, right: 2512, bottom: 2860)
    PriceTerm.create(text: "20,00", left: 1937, top: 3426, right: 2049, bottom: 3460)
    PriceTerm.create(text: "7,81", left: 2471, top: 3427, right: 2551, bottom: 3460)
    PriceTerm.create(text: "39,04", left: 2702, top: 3425, right: 2812, bottom: 3460)

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq BigDecimal('39.04')
    expect(prices.vat_amount).to eq BigDecimal('7.81')
  end

  it 'sets the prices to nil if there are no words' do
    prices = PriceCalculation.new([])
    expect(prices.net_amount).to be_nil
    expect(prices.vat_amount).to be_nil
  end

  it 'accepts a price term including a € symbol' do
    PriceTerm.create(text: '€86.97', left: '2355', right: '2528', top: '1790', bottom: '1827')
    PriceTerm.create(text: '€86.97', left: '2359', right: '2525', top: '1926', bottom: '1962')
    PriceTerm.create(text: '€86.97', left: '2355', right: '2528', top: '2065', bottom: '2101')

    prices = PriceCalculation.new(PriceTerm.dataset)
    expect(prices.net_amount).to eq BigDecimal('86.97')
    expect(prices.vat_amount).to eq BigDecimal('0')
  end

  def word(attributes = {})
    double(:word,
           text: attributes[:text],
           to_d: BigDecimal.new(attributes[:text].sub(/,/, '.')),
           bounding_box: double(:bounding_box, attributes[:bounding_box] || {}))
  end
end
