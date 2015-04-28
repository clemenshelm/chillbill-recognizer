require_relative '../../lib/calculations/price_calculation'

describe PriceCalculation do
  it 'calculates the sub total and the VAT total' do
    words = %w(14.49 2.69 8.19 46.85 0.0 18.79 28.06 20.0 7.81 39.04 100.0).
      map { |text| word(text: text)  }

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('39.04')
    expect(prices.vat_amount).to eq BigDecimal('7.81')
  end

  it 'calculates the sub total and the VAT total for a different bill' do
    words = %w(1.0, 5.19, 7.78, 6.48, 1.3).map { |text| word(text: text) }

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('6.48')
    expect(prices.vat_amount).to eq BigDecimal('1.3')
  end

  it 'takes the right amount if there is no VAT' do
    words = [
      word(text: '1.185,00', bounding_box: {x: 2199, y: 1996, width: 151, height: 33}),
      word(text: '15,41', bounding_box: { x: 2768, y: 1995, width: 91, height: 35 })
    ]

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('15.41')
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the right amount if the VAT is 0' do
    words = [
      word(text: '80,00', bounding_box: {x: 2320, y: 2033, width: 110, height: 37}),
      word(text: '80,00', bounding_box: {x: 2576, y: 2034, width: 110, height: 37}),
      word(text: '80,00', bounding_box: {x: 2576, y: 2215, width: 110, height: 38}),
      word(text: '0,00', bounding_box: {x: 2300, y: 2305, width: 86, height: 37}),
      word(text: '0,00', bounding_box: {x: 2599, y: 2306, width: 86, height: 37}),
      word(text: '80,00', bounding_box: {x: 2574, y: 2403, width: 112, height: 40})
    ]

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('80.00')
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the highes net amount and VAT amount if there are many possibilities' do
    words = [
      word(text: "14,49", bounding_box: {x: 2703, y: 1313, width: 110, height: 36}),
      word(text: "14,49", bounding_box: {x: 2704, y: 1433, width: 109, height: 36}),
      word(text: "2,69", bounding_box: {x: 2724, y: 1556, width: 88, height: 36}),
      word(text: "8,19", bounding_box: {x: 2725, y: 1676, width: 87, height: 36}),
      word(text: "46,85", bounding_box: {x: 2702, y: 1916, width: 112, height: 39}),
      word(text: "46,85", bounding_box: {x: 2701, y: 2037, width: 111, height: 35}),
      word(text: "0,00", bounding_box: {x: 2724, y: 2098, width: 87, height: 36}),
      word(text: "46,85", bounding_box: {x: 2702, y: 2104, width: 192, height: 189}),
      word(text: "0,00", bounding_box: {x: 2724, y: 2279, width: 88, height: 34}),
      word(text: "46,85", bounding_box: {x: 2701, y: 2399, width: 113, height: 38}),
      word(text: "18,79", bounding_box: {x: 2703, y: 2519, width: 109, height: 36}),
      word(text: "28,06", bounding_box: {x: 2701, y: 2580, width: 111, height: 35}),
      word(text: "28,06", bounding_box: {x: 2400, y: 2823, width: 112, height: 37}),
      word(text: "20,00", bounding_box: {x: 1937, y: 3426, width: 112, height: 34}),
      word(text: "7,81", bounding_box: {x: 2471, y: 3427, width: 80, height: 33}),
      word(text: "39,04", bounding_box: {x: 2702, y: 3425, width: 110, height: 35})
    ]

    prices = PriceCalculation.new(words)
    expect(prices.net_amount).to eq BigDecimal('39.04')
    expect(prices.vat_amount).to eq BigDecimal('7.81')
  end

  def word(attributes = {})
    double(:word,
           text: attributes[:text],
           to_d: BigDecimal.new(attributes[:text].sub(/,/, '.')),
           bounding_box: double(:bounding_box, attributes[:bounding_box] || {}))
  end
end
