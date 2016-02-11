require_relative '../../lib/detectors/price_detector'

describe PriceDetector do
  it 'finds prices separated with a comma' do
    words = [
      double(text: 'C'),
      double(text: '14,49'),
      double(text: '4006972047414'),
      double(text: '2,69')
    ]

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq %w(14,49 2,69)
  end

  it 'handles invalid UTF8 characters' do
    pending 'move to word unit tests as invalid utf8 characters are handled there'
    words = [
      double(text: "S\xE2\x80raße"),
      double(text: '2,69')
    ]

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq %w(2,69)
  end

  it "doesn't find words that contain no numbers" do
    words = [
      double(text: '/,v„'),
      double(text: 'Sie,')
    ]

    prices = PriceDetector.filter(words)
    expect(prices).to be_empty
  end

  it "doesn't find words with 4 decimal places" do
    word = double(text: '5,1920')

    prices = PriceDetector.filter([word])
    expect(prices).to be_empty
  end

  it 'finds prices that consist of 2 words' do
    words = [
      double(text: '54,'),
      double(text: '00')
    ]

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq %w(54,00)
  end

  it 'finds prices that consist of 3 words' do
    words = [
      double(text: '45'),
      double(text: ','),
      double(text: '00')
    ]

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq %w(45,00)
  end

  it 'only find prices with typical characters' do
    words = %w(02/2015 N24 1.185,00).map { |text| double(text: text) }

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq ['1.185,00']
  end

  it "doesn't find prices that contain letters" do
    words = %w(12 x 0,95).map { |text| double(text: text) }

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq %w(0,95)
  end

  it "includes a word's bounding box" do
    word = double(text: '1.185,00', bounding_box: double(x: 2199, y: 1996, width: 151, height: 33))

    prices = PriceDetector.filter([word])
    bounding_box = prices.first.bounding_box
    expect(bounding_box.x).to eq 2199
    expect(bounding_box.y).to eq 1996
    expect(bounding_box.width).to eq 151
    expect(bounding_box.height).to eq 33
  end

  it 'finds prices with a colon as decimal separator' do
    price_texts = %w(10.00 27.20 1.35 1.50 27.34)
    words = price_texts.map { |text| double(text: text) }

    prices = PriceDetector.filter(words)
    expect(prices.map(&:text)).to eq price_texts
  end

  it "doesn't find dates as prices" do
    price_texts = %w(28.02.15 31.03.15)
    words = price_texts.map { |text| double(text: text) }

    prices = PriceDetector.filter(words)
    expect(prices).to be_empty
  end
end
