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
    expect(prices.map(&:text)).to eq ['11 038']
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

  it 'does not detect numbers before kg' do
    # From 25KA7rWWmhStXDEsb.pdf
    create(
    :word,
    text: '36,80',
    left: 0.7706151832460733,
    right: 0.8072643979057592,
    top: 0.8700277520814061,
    bottom: 0.8792784458834413
    )

    create(
    :word,
    text: 'kg',
    left: 0.8118455497382199,
    right: 0.8255890052356021,
    top: 0.8697964847363552,
    bottom: 0.8799722479185939
    )

    create(
    :word,
    text: '4,24',
    left: 0.7797774869109948,
    right: 0.8049738219895288,
    top: 0.45351526364477335,
    bottom: 0.4616096207215541
    )

    create(
    :word,
    text: 'kg',
    left: 0.8095549738219895,
    right: 0.8232984293193717,
    top: 0.45351526364477335,
    bottom: 0.46207215541165586
    )

    create(
    :word,
    text: '3,76',
    left: 0.7797774869109948,
    right: 0.805628272251309,
    top: 0.4081868640148011,
    bottom: 0.4162812210915819
    )

    create(
    :word,
    text: 'kg',
    left: 0.8095549738219895,
    right: 0.8232984293193717,
    top: 0.4081868640148011,
    bottom: 0.4167437557816836
    )

    create(
    :word,
    text: '€',
    left: 0.05791884816753927,
    right: 0.06675392670157068,
    top: 0.8499074930619797,
    bottom: 0.8584643848288621
    )

    create(
    :word,
    text: '260,00',
    left: 0.07264397905759162,
    right: 0.12238219895287958,
    top: 0.8499074930619797,
    bottom: 0.8598519888991675
    )

    create(
    :word,
    text: '€',
    left: 0.2005890052356021,
    right: 0.2094240837696335,
    top: 0.8499074930619797,
    bottom: 0.8584643848288621
    )

    create(
    :word,
    text: '45,00',
    left: 0.21498691099476439,
    right: 0.25589005235602097,
    top: 0.8499074930619797,
    bottom: 0.8598519888991675
    )

    create(
    :word,
    text: '€',
    left: 0.3530759162303665,
    right: 0.3619109947643979,
    top: 0.8499074930619797,
    bottom: 0.8584643848288621
    )

    create(
    :word,
    text: '305,00',
    left: 0.36780104712041883,
    right: 0.4178664921465969,
    top: 0.8499074930619797,
    bottom: 0.8598519888991675
    )

    create(
    :word,
    text: '20',
    left: 0.4869109947643979,
    right: 0.5042539267015707,
    top: 0.8499074930619797,
    bottom: 0.8584643848288621
    )

    create(
    :word,
    text: '€',
    left: 0.5768979057591623,
    right: 0.5857329842931938,
    top: 0.8499074930619797,
    bottom: 0.8584643848288621
    )

    create(
    :word,
    text: '61,00',
    left: 0.5916230366492147,
    right: 0.6321989528795812,
    top: 0.8499074930619797,
    bottom: 0.8598519888991675
    )

    create(
    :word,
    text: '€',
    left: 0.7257853403141361,
    right: 0.7346204188481675,
    top: 0.8499074930619797,
    bottom: 0.8584643848288621
    )

    create(
    :word,
    text: '366,00',
    left: 0.7405104712041884,
    right: 0.7905759162303665,
    top: 0.8499074930619797,
    bottom: 0.8598519888991675
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ["260,00", "45,00", "305,00", "61,00", "366,00"]
  end

  # TODO: Move to general helpers
  def create_following_words(texts)
    texts.each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 90)
    end
  end
end
