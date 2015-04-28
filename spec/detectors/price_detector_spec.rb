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
end
