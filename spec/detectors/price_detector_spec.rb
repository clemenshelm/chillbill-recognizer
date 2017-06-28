# frozen_string_literal: true
require_relative '../../lib/detectors/price_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe PriceDetector do
  it 'finds prices separated with a comma' do
    %w(C 14,49 4006972047414 2,69).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(14,49 2,69)
  end

  it "doesn't find words that contain no numbers" do
    %w(/,v„ Sie).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices).to be_empty
  end

  it "doesn't find words with 4 decimal places" do
    create(:word, text: '5,1920')

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'finds prices that consist of 2 words' do
    create_following_words(['54,', '00'])

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(54,00)
  end

  it 'finds prices that consist of 3 words' do
    create_following_words(%w(45 , 00))

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(45,00)
  end

  it 'only find prices with typical characters' do
    %w(02/2015 N24 1.185,00).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['1.185,00']
  end

  it "doesn't find prices that contain letters" do
    %w(12 x 0,95).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(0,95)
  end

  it "includes a word's bounding box" do
    create(
      :word,
      text: '1.185,00',
      left: 2199,
      top: 1996,
      right: 2350,
      bottom: 2029
    )

    prices = PriceDetector.filter
    price = prices.first
    expect(price.left).to eq 2199
    expect(price.top).to eq 1996
    expect(price.width).to eq 151
    expect(price.height).to eq 33
  end

  it 'finds prices with a colon as decimal separator' do
    price_texts = %w(10.00 27.20 1.35 1.50 27.34)
    price_texts.each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq price_texts
  end

  it "doesn't find dates as prices" do
    %w(28.02.15 31.03.15).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'recognizes correct prices with a period as thousand separator' do
    %w(3.551,37 4.261,64).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    price_strings = prices.map { |price| format('%.2f', price.to_d) }
    expect(price_strings).to eq ['3551.37', '4261.64']
  end

  it 'recognizes correct prices with a period as decimal separator' do
    price_texts = %w(10.00 27.20 1.35 1.50 27.34)
    price_texts.each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    price_strings = prices.map { |price| format('%.2f', price.to_d) }
    expect(price_strings).to eq price_texts
  end

  it 'recognizes prices with leading euro symbol' do
    create(:word, text: '€86.97')

    prices = PriceDetector.filter
    price_string = format('%.2f', prices.first.to_d)
    expect(price_string).to eq('86.97')
  end

  it 'recognizes a price with a dash as decimal places' do
    create(:word, text: '1000,-')

    prices = PriceDetector.filter
    price_string = format('%.2f', prices.first.to_d)
    expect(price_string).to eq('1000.00')
  end

  it 'finds a price without decimal places with the currency name behind' do
    # from bill gANywe3fjvx98iPp2
    create(
      :word,
      text: '360',
      left: 1048,
      right: 1134,
      top: 1826,
      bottom: 1859
    )

    create(
      :word,
      text: 'Euro',
      left: 1160,
      right: 1260,
      top: 1826,
      bottom: 1859
    )

    prices = PriceDetector.filter
    price_string = format('%.2f', prices.first.to_d)
    expect(price_string).to eq('360.00')
  end

  it 'finds a price without decimal places with the currency symbol behind' do
    # from bill gANywe3fjvx98iPp2
    create(
      :word,
      text: '300€',
      left: 1890,
      right: 2012,
      top: 1350,
      bottom: 1384
    )

    prices = PriceDetector.filter
    price_string = format('%.2f', prices.first.to_d)
    expect(price_string).to eq('300.00')
  end

  it 'finds hungarian price that consist of 2 words' do
    # from bill Thzi7n3qdSk4awip2
    create_following_words(%w(11 038))
    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['11 038 ']
  end

  it 'detects price with comma and period separator' do
    # from bill fP5Y5WXQGoF45YePr

    create(
      :word,
      text: '€1',
      left: 0.788027477919529,
      right: 0.8004579653254825,
      top: 0.39532731899144113,
      bottom: 0.4022669442516771
    )

    create(
      :word,
      text: ',202.16',
      left: 0.8043833824010468,
      right: 0.8472358521426235,
      top: 0.39555863983344897,
      bottom: 0.4034235484617164
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['€1,202.16']
  end

  it 'does not detect numbers with only one decimal digit' do
    # from bill kk4FafcZqvCCC64BY.pdf
    create(
      :word,
      text: '3.0',
      left: 0.48528449967298887,
      right: 0.5032701111837803,
      top: 0.42298797409805733,
      bottom: 0.4296947271045328
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect vat-rate as price' do
    # from bill BYnCDzw7nNMFergRW.pdf
    create(
      :word,
      text: '20,00%',
      left: 0.5981033355134074,
      right: 0.6530412034009156,
      top: 0.4898242368177613,
      bottom: 0.5
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect a list of numbers as prices' do
    # from 2AAizxTARPRp8PN4D.pdf
    create(
      :word,
      text: '01,',
      left: 0.41216879293424924,
      right: 0.43277723258096173,
      top: 0.5047420772611613,
      bottom: 0.5146888734674995
    )

    create(
      :word,
      text: '02,',
      left: 0.4383382401046778,
      right: 0.45894667975139025,
      top: 0.5047420772611613,
      bottom: 0.5146888734674995
    )

    create(
      :word,
      text: 'O3',
      left: 0.46450768727510633,
      right: 0.48086359175662413,
      top: 0.5047420772611613,
      bottom: 0.5130696275734443
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect paper size followed by quantity as a price' do
    # From 2HtXGWoynP3sFMvFH.pdf
    create(
      :word,
      text: 'A5,',
      left: 0.16328534031413613,
      right: 0.18291884816753926,
      top: 0.31059204440333027,
      bottom: 0.3191489361702128
    )

    create(
      :word,
      text: '32',
      left: 0.1888089005235602,
      right: 0.2032068062827225,
      top: 0.31059204440333027,
      bottom: 0.3179925994449584
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'detects a price after EUR' do
    # From 2D6A3fe8Ggpovv3EF.pdf
    create(
      :word,
      text: 'EUR',
      left: 0.6587068332108743,
      right: 0.6958119030124909,
      top: 0.41488539788823076,
      bottom: 0.42467164563481846
    )

    create(
      :word,
      text: '14,90',
      left: 0.7038941954445261,
      right: 0.74834680382072,
      top: 0.41514293072366726,
      bottom: 0.42621684264743753
    )

    create(
      :word,
      text: 'EUR',
      left: 0.8475385745775166,
      right: 0.884643644379133,
      top: 0.41488539788823076,
      bottom: 0.42467164563481846
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq(%w(14,90))
  end

  it 'does not detect pieces as prices' do
    # from bill 29pwjsKx88nhnQKm9.pdf

    # Dummy dimension values for the bill
    BillDimension.create_all(width: 3056, height: 4324)

    create(
      :word,
      text: 'Menge',
      left: 0.6013185287994448,
      right: 0.6544066620402498,
      top: 0.42119769481332997,
      bottom: 0.43297419193184666
    )

    create(
      :word,
      text: '1,00',
      left: 0.6210964607911172,
      right: 0.6492019430950728,
      top: 0.4560260586319218,
      bottom: 0.46579804560260585
    )

    create(
      :word,
      text: '2,00',
      left: 0.6197085357390701,
      right: 0.6492019430950728,
      top: 0.4845903282385367,
      bottom: 0.49436231520922075
    )

    create(
      :word,
      text: '1,00',
      left: 0.6210964607911172,
      right: 0.6492019430950728,
      top: 0.5276872964169381,
      bottom: 0.5374592833876222
    )

    create(
      :word,
      text: '8,50',
      left: 0.9389312977099237,
      right: 0.9687716863289383,
      top: 0.4560260586319218,
      bottom: 0.46579804560260585
    )

    create(
      :word,
      text: '12,00',
      left: 0.9309507286606523,
      right: 0.9684247050659265,
      top: 0.4845903282385367,
      bottom: 0.49436231520922075
    )

    create(
      :word,
      text: '4,00',
      left: 0.9385843164469119,
      right: 0.9687716863289383,
      top: 0.5276872964169381,
      bottom: 0.5374592833876222
    )

    create(
      :word,
      text: '17',
      left: 0.7394170714781402,
      right: 0.7678695350451076,
      top: 0.08694562766224004,
      bottom: 0.09771986970684039
    )

    create(
      :word,
      text: '2152',
      left: 0.7744621790423317,
      right: 0.8223455933379598,
      top: 0.08669506389376096,
      bottom: 0.09596592332748685
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['8,50', '12,00', '4,00']
  end

  # TODO: Move to general helpers
  def create_following_words(texts)
    texts.each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 90)
    end
  end
end
