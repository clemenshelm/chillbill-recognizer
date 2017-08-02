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

  it "includes a word's bounding box", :focus do
    # From fP5Y5WXQGoF45YePr.pdf
    create(
      :word,
      text: '7,99',
      left: 0.8196989528795812,
      right: 0.9021596858638743,
      top: 0.6372569963682974,
      bottom: 0.6646015808587908
    )

    prices = PriceDetector.filter
    price = prices.first

    expect(price.left).to eq 0.8196989528795812
    expect(price.top).to eq 0.6372569963682974
    expect(price.width).to eq 0.08246073298429313
    expect(price.height).to eq 0.027344584490493484
  end

  it 'finds prices with a colon as decimal separator' do
    price_texts = %w(10.00 27.20 1.35 1.50 27.34)
    price_texts.each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq price_texts
  end

  it "doesn't find dates as prices" do
    %w(28.02.15 31.03.15 29.12.15).each { |text| create(:word, text: text) }

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
    # Missing Label - needs price without decimal places following currency name
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
    # Missing Label - needs  price, without decimal places, behind a symbol
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
    # From bill Thzi7n3qdSk4awip2.pdf
    create_following_words(%w(11 038))
    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['11 038 ']
  end

  it 'detects price with comma and period separator' do
    # From bill fP5Y5WXQGoF45YePr.pdf

    create(
      :word,
      text: '€1',
      left: 0.8410206084396468,
      right: 0.8534510958456003,
      top: 0.45061300023132084,
      bottom: 0.4575526254915568
    )

    create(
      :word,
      text: ',202.16',
      left: 0.8573765129211646,
      right: 0.9002289826627412,
      top: 0.4508443210733287,
      bottom: 0.4587092297015961
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['€1,202.16']
  end

  it 'does not detect numbers with only one decimal digit' do
    # From bill kk4FafcZqvCCC64BY.pdf
    create(
      :word,
      text: '3.0',
      left: 0.5810987573577502,
      right: 0.5990843688685416,
      top: 0.4757169287696577,
      bottom: 0.4824236817761332
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect vat-rate as price' do
    # From bill BYnCDzw7nNMFergRW.pdf
    create(
      :word,
      text: '20,00%',
      left: 0.699051357540072,
      right: 0.750408897612038,
      top: 0.5995836224843858,
      bottom: 0.609530418690724
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect a list of numbers as prices' do
    # From 2AAizxTARPRp8PN4D.pdf
    create(
      :word,
      text: '01,',
      left: 0.4124959110238796,
      right: 0.4331043506705921,
      top: 0.5049733981031691,
      bottom: 0.5149201943095073
    )

    create(
      :word,
      text: '02,',
      left: 0.43866535819430813,
      right: 0.4592737978410206,
      top: 0.5049733981031691,
      bottom: 0.5149201943095073
    )

    create(
      :word,
      text: 'O3',
      left: 0.46483480536473665,
      right: 0.4811907098462545,
      top: 0.5049733981031691,
      bottom: 0.5133009484154523
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect paper size followed by quantity as a price' do
    # From 2HtXGWoynP3sFMvFH.pdf
    create(
      :word,
      text: 'A5,',
      left: 0.243782722513089,
      right: 0.26341623036649214,
      top: 0.3628584643848289,
      bottom: 0.3714153561517114
    )

    create(
      :word,
      text: '32',
      left: 0.2693062827225131,
      right: 0.2837041884816754,
      top: 0.3628584643848289,
      bottom: 0.370259019426457
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'detects a price after EUR' do
    # From 2D6A3fe8Ggpovv3EF.pdf
    create(
      :word,
      text: 'EUR',
      left: 0.8684985279685966,
      right: 0.9018645731108931,
      top: 0.4938699976867916,
      bottom: 0.5026601896830905
    )

    create(
      :word,
      text: '14,90',
      left: 0.9087340529931305,
      right: 0.948642459928034,
      top: 0.4938699976867916,
      bottom: 0.5045107564191533
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq(%w(14,90))
  end

  it 'does not detect pieces as prices' do
    # From bill 29pwjsKx88nhnQKm9.pdf

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

    create(
      :word,
      text: '1,00',
      left: 0.5978403141361257,
      right: 0.6243455497382199,
      top: 0.4551341350601295,
      bottom: 0.4641535615171138
    )

    create(
      :word,
      text: '8,50',
      left: 0.6861910994764397,
      right: 0.7143324607329843,
      top: 0.4551341350601295,
      bottom: 0.4641535615171138
    )

    create(
      :word,
      text: '2,00',
      left: 0.5965314136125655,
      right: 0.6243455497382199,
      top: 0.48149861239592967,
      bottom: 0.49051803885291395
    )

    create(
      :word,
      text: '12,00',
      left: 0.8900523560209425,
      right: 0.925392670157068,
      top: 0.48149861239592967,
      bottom: 0.49051803885291395
    )

    create(
      :word,
      text: '1,00',
      left: 0.5978403141361257,
      right: 0.6243455497382199,
      top: 0.5212765957446809,
      bottom: 0.5302960222016652
    )

    create(
      :word,
      text: '4,00',
      left: 0.6858638743455497,
      right: 0.7143324607329843,
      top: 0.5212765957446809,
      bottom: 0.5302960222016652
    )

    create(
      :word,
      text: '501.1.0663',
      left: 0.24083769633507854,
      right: 0.31544502617801046,
      top: 0.4946808510638298,
      bottom: 0.5023126734505088
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['8,50', '12,00', '4,00']
  end

  it 'detects negative prices' do
    # from bill 2D7BuHc3f8wAmb4y8.pdf
    create(
      :word,
      text: '-12,00',
      left: 0.8792539267015707,
      right: 0.9198298429319371,
      top: 0.41676313961565176,
      bottom: 0.4264876128733503
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['-12,00']
  end

  # TODO: Move to general helpers
  def create_following_words(texts)
    texts.each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 90)
    end
  end
end
