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
    create_following_words(%w(54, 00))

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

  # TODO: Move to general helpers
  def create_following_words(texts)
    texts.each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 90)
    end
  end
end
