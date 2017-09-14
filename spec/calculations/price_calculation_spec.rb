# frozen_string_literal: true
require_relative '../../lib/calculations/price_calculation'

describe PriceCalculation do
  it 'calculates the sub total and the VAT total' do
    %w(14.49 2.69 8.19 46.85 0.0 18.79 28.06 20.0 7.81 39.04 100.0)
      .each { |text| PriceTerm.create(text: text) }

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq BigDecimal('3904.0')
    expect(prices.vat_amount).to eq BigDecimal('781.0')
  end

  it 'calculates the sub total and the VAT total for a different bill' do
    %w(1.0 5.19 7.78 6.48 1.3).map { |text| PriceTerm.create(text: text) }

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq BigDecimal('648.0')
    expect(prices.vat_amount).to eq BigDecimal('130.0')
  end

  it 'takes the right amount if there is no VAT' do
    # Missing Label - needs amount without VAT
    PriceTerm.create(
      text: '1.185,00',
      left: 2199,
      top: 1996,
      right: 2350,
      bottom: 2029
    )

    PriceTerm.create(
      text: '15,41',
      left: 2768,
      top: 1995,
      right: 2859,
      bottom: 2030
    )

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq BigDecimal('1541')
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the right amount if the VAT is 0' do
    # Missing Label - needs a price with 0% vat
    PriceTerm.create(
      text: '80,00',
      left: 2320,
      top: 2033,
      right: 2430,
      bottom: 2070
    )

    PriceTerm.create(
      text: '80,00',
      left: 2576,
      top: 2034,
      right: 2686,
      bottom: 2071
    )

    PriceTerm.create(
      text: '80,00',
      left: 2576,
      top: 2215,
      right: 2686,
      bottom: 2253
    )

    PriceTerm.create(
      text: '0,00',
      left: 2300,
      top: 2305,
      right: 2386,
      bottom: 2342
    )

    PriceTerm.create(
      text: '0,00',
      left: 2599,
      top: 2306,
      right: 2685,
      bottom: 2343
    )

    PriceTerm.create(
      text: '80,00',
      left: 2574,
      top: 2403,
      right: 2686,
      bottom: 2443
    )

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq BigDecimal('8000')
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the highest right amount if there are multiple' do
    # Missing Label - needs several prices without vats
    PriceTerm.create(
      text: '190,00',
      left: 2706,
      top: 1559,
      right: 2824,
      bottom: 1596
    )

    PriceTerm.create(
      text: '80,00',
      left: 2726,
      top: 1619,
      right: 2823,
      bottom: 1656
    )

    PriceTerm.create(
      text: '80,00',
      left: 2724,
      top: 1680,
      right: 2823,
      bottom: 1717
    )

    PriceTerm.create(
      text: '350,00',
      left: 657,
      top: 3397,
      right: 833,
      bottom: 3450
    )

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq 35_000.0
    expect(prices.vat_amount).to eq 0
  end

  it 'takes the highes net amount and VAT amount if there are many choices' do
    # Missing Label - needs several prices with vats
    PriceTerm.create(
      text: '14,49',
      left: 2703,
      top: 1313,
      right: 2813,
      bottom: 1349
    )

    PriceTerm.create(
      text: '14,49',
      left: 2704,
      top: 1433,
      right: 2813,
      bottom: 1469
    )

    PriceTerm.create(
      text: '2,69',
      left: 2724,
      top: 1556,
      right: 2812,
      bottom: 1592
    )

    PriceTerm.create(
      text: '8,19',
      left: 2725,
      top: 1676,
      right: 2812,
      bottom: 1712
    )

    PriceTerm.create(
      text: '46,85',
      left: 2702,
      top: 1916,
      right: 2814,
      bottom: 1955
    )

    PriceTerm.create(
      text: '46,85',
      left: 2701,
      top: 2037,
      right: 2812,
      bottom: 2133
    )

    PriceTerm.create(
      text: '0,00',
      left: 2724,
      top: 2098,
      right: 2811,
      bottom: 2134
    )

    PriceTerm.create(
      text: '46,85',
      left: 2702,
      top: 2104,
      right: 2894,
      bottom: 2293
    )

    PriceTerm.create(
      text: '0,00',
      left: 2724,
      top: 2279,
      right: 2812,
      bottom: 2313
    )

    PriceTerm.create(
      text: '46,85',
      left: 2701,
      top: 2399,
      right: 2814,
      bottom: 2437
    )

    PriceTerm.create(
      text: '18,79',
      left: 2703,
      top: 2519,
      right: 2812,
      bottom: 2555
    )

    PriceTerm.create(
      text: '28,06',
      left: 2701,
      top: 2580,
      right: 2812,
      bottom: 2615
    )

    PriceTerm.create(
      text: '28,06',
      left: 2400,
      top: 2823,
      right: 2512,
      bottom: 2860
    )

    PriceTerm.create(
      text: '20,00',
      left: 1937,
      top: 3426,
      right: 2049,
      bottom: 3460
    )

    PriceTerm.create(
      text: '7,81',
      left: 2471,
      top: 3427,
      right: 2551,
      bottom: 3460
    )

    PriceTerm.create(
      text: '39,04',
      left: 2702,
      top: 3425,
      right: 2812,
      bottom: 3460
    )

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq BigDecimal('3904.0')
    expect(prices.vat_amount).to eq BigDecimal('781.0')
  end

  it 'sets the prices to nil if there are no words' do
    prices = PriceCalculation.new
    expect(prices.net_amount).to be_nil
    expect(prices.vat_amount).to be_nil
  end

  it 'accepts a price term including a € symbol' do
    # Missing Label - needs a price with a euro symbol
    PriceTerm.create(
      text: '€86.97',
      left: '2355',
      right: '2528',
      top: '1790',
      bottom: '1827'
    )

    PriceTerm.create(
      text: '€86.97',
      left: '2359',
      right: '2525',
      top: '1926',
      bottom: '1962'
    )

    PriceTerm.create(
      text: '€86.97',
      left: '2355',
      right: '2528',
      top: '2065',
      bottom: '2101'
    )

    prices = PriceCalculation.new
    expect(prices.net_amount).to eq BigDecimal('8697.0')
    expect(prices.vat_amount).to eq BigDecimal('0')
  end

  it 'removes detected pieces as prices' do
    # From 29pwjsKx88nhnQKm9.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: 'Menge',
      left: 0.5791884816753927,
      right: 0.6292539267015707,
      top: 0.42298797409805733,
      bottom: 0.4338575393154487
    )

    PriceTerm.create(
      text: '1,00',
      left: 0.5978403141361257,
      right: 0.6243455497382199,
      top: 0.4551341350601295,
      bottom: 0.4641535615171138
    )

    PriceTerm.create(
      text: '8,50',
      left: 0.6861910994764397,
      right: 0.7143324607329843,
      top: 0.4551341350601295,
      bottom: 0.4641535615171138
    )

    PriceTerm.create(
      text: '2,00',
      left: 0.5965314136125655,
      right: 0.6243455497382199,
      top: 0.48149861239592967,
      bottom: 0.49051803885291395
    )

    PriceTerm.create(
      text: '12,00',
      left: 0.8900523560209425,
      right: 0.925392670157068,
      top: 0.48149861239592967,
      bottom: 0.49051803885291395
    )

    PriceTerm.create(
      text: '1,00',
      left: 0.5978403141361257,
      right: 0.6243455497382199,
      top: 0.5212765957446809,
      bottom: 0.5302960222016652
    )

    PriceTerm.create(
      text: '4,00',
      left: 0.6858638743455497,
      right: 0.7143324607329843,
      top: 0.5212765957446809,
      bottom: 0.5302960222016652
    )

    PriceCalculation.remove_false_positives
    expect(price_strings).to eq ['8,50', '12,00', '4,00']
  end

  it 'removes numbers below Anz.' do
    # From ihfDXTa64yYbFLa6Y.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: 'Anz.',
      left: 0.1197252208047105,
      right: 0.1573438011122015,
      top: 0.475937066173068,
      bottom: 0.4854234150856085
    )

    PriceTerm.create(
      text: '32,00',
      left: 0.1122015047432123,
      right: 0.1573438011122015,
      top: 0.5016196205460435,
      bottom: 0.512494215640907
    )

    PriceCalculation.remove_false_positives
    expect(price_strings).to be_empty
  end

  it 'deletes prices which are not in part of a quantity' do
    # From rDxLnivxoXQw9nWa7.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: 'Menge',
      left: 0.5785340314136126,
      right: 0.6285994764397905,
      top: 0.4225254394079556,
      bottom: 0.4333950046253469
    )

    PriceTerm.create(
      text: '1,00',
      left: 0.5971858638743456,
      right: 0.6236910994764397,
      top: 0.5074005550416282,
      bottom: 0.5164199814986123
    )

    PriceTerm.create(
      text: '1,00',
      left: 0.5971858638743456,
      right: 0.6236910994764397,
      top: 0.5208140610545791,
      bottom: 0.5298334875115633
    )

    PriceTerm.create(
      text: '5,00',
      left: 0.6855366492146597,
      right: 0.7136780104712042,
      top: 0.5208140610545791,
      bottom: 0.5298334875115633
    )

    PriceTerm.create(
      text: '431,25',
      left: 0.09325916230366492,
      right: 0.1387434554973822,
      top: 0.8237742830712304,
      bottom: 0.8327937095282146
    )

    PriceTerm.create(
      text: '86,25',
      left: 0.21171465968586387,
      right: 0.24803664921465968,
      top: 0.8237742830712304,
      bottom: 0.8327937095282146
    )

    PriceTerm.create(
      text: '517,50',
      left: 0.837696335078534,
      right: 0.8828534031413613,
      top: 0.8237742830712304,
      bottom: 0.8327937095282146
    )

    PriceCalculation.remove_false_positives
    expect(price_strings).to eq ['5,00', '431,25', '86,25', '517,50']
  end

  it 'deletes detected date as price' do
    # From C5sri9hxpbDhha68D.png
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    PriceTerm.create(
      text: '10.05',
      left: 0.521978021978022,
      right: 0.6131868131868132,
      top: 0.724,
      bottom: 0.737
    )

    create(
      :word,
      text: '.',
      left: 0.6230769230769231,
      right: 0.6263736263736264,
      top: 0.735,
      bottom: 0.737
    )

    create(
      :word,
      text: '17',
      left: 0.6373626373626373,
      right: 0.6703296703296703,
      top: 0.724,
      bottom: 0.7375
    )

    PriceCalculation.remove_false_positives
    expect(price_strings).to be_empty
  end

  def price_strings
    PriceTerm.map(&:to_s)
  end

  def word(attributes = {})
    double(:word,
           text: attributes[:text],
           to_d: BigDecimal.new(attributes[:text].sub(/,/, '.')),
           bounding_box: double(:bounding_box, attributes[:bounding_box] || {}))
  end
end
