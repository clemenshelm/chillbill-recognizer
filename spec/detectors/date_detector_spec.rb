
require_relative '../../lib/detectors/date_detector'

describe DateDetector, :focus do
  it 'finds short German dates' do
    # From bill m6jLaPhmWvuZZqSXy
    words = [
      double(text: '9025'),
      double(text: '0650/004/133'),
      double(text: '04.04.2015'),
      double(text: '13133')
    ]

    dates = DateDetector.filter(words)
    expect(dates.map(&:text)).to eq %w(04.04.2015)
  end

  it 'does not find dates connected to other words' do
    # From bill m6jLaPhmWvuZZqSXy
    words = [
      double(text: '04.04.2015/13132257')
    ]

    dates = DateDetector.filter(words)
    expect(dates).to be_empty
  end

  it 'detects multiple dates in a document' do
    # From bill 4f5mhL6zBb3cyny7n
    words = [
      double(text: '01.04.2015'),
      double(text: '28.02.15'),
      double(text: '31.03.15'),
      double(text: '31.03.15'),
      double(text: '27.02.2015'),
      double(text: '31.03.15'),
      double(text: '16.03.15'),
      double(text: '16.03.15')
    ]

    dates = DateDetector.filter(words)
    expect(dates.map(&:text)).to eq %w(01.04.2015 28.02.15 31.03.15 31.03.15 27.02.2015 31.03.15 16.03.15 16.03.15)
  end

  it 'detects dates spread over several words' do
    # From bill XYt8oerHesxQkdwvp
    words = [
      double(text: '10', bounding_box: double(x: 1623, y: 536, width: 24, height: 28)),
      double(text: '04.2015', bounding_box: double(x: 1664, y: 536, width: 69, height: 27))
    ]

    dates = DateDetector.filter(words)
    expect(dates.first.text).to eq '10.04.2015'
  end

  it 'filters number combinations with too many digits' do
    words = [double(text: '2.5617.96')]

    dates = DateDetector.filter(words)
    expect(dates).to be_empty
  end

  it 'detects dates in compound words' do
    words = [double(text: 'Lief.dat.:13.04.15')]

    dates = DateDetector.filter(words)
    expect(dates.first.text).to eq '13.04.15'
  end

  it 'ignores non-dates' do
    words = [double(text: 'Lief.dat.:')]

    dates = DateDetector.filter(words)
    expect(dates).to be_empty
  end

  it 'detects full German dates' do
    words = [
      double(text: '23.'),
      double(text: 'April'),
      double(text: '2015')
    ]

    dates = DateDetector.filter(words)
    expect(dates.first.text).to eq '23. April 2015'
  end

  it 'does not recognize a number out of a date range' do
    words = [double(text: '41.14.122')]

    dates = DateDetector.filter(words)
    expect(dates).to be_empty
  end
end
