require_relative '../../lib/boot'
require_relative '../../lib/detectors/date_detector'
require_relative '../../lib/models/word'

describe DateDetector, :focus do
  before(:each) do
    Word.dataset.delete
    DateTerm.dataset.delete
  end

  it 'finds short German dates' do
    # From bill m6jLaPhmWvuZZqSXy
    %w(9025 0650/004/133 04.04.2015 13133).each { |text| Word.create(text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-04']
  end

  it 'does finds dates connected to other words' do
    # From bill m6jLaPhmWvuZZqSXy
    Word.create(text: '04.04.2015/13132257')

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-04']
  end

  it 'detects multiple dates in a document' do
    # From bill 4f5mhL6zBb3cyny7n
    %w(01.04.2015 28.02.15 31.03.15 27.02.2015 16.03.15)
      .each { |text| Word.create(text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq %w(2015-04-01 2015-02-28 2015-03-31
      2015-02-27 2015-03-16)
  end

  it 'detects dates spread over several words' do
    # From bill XYt8oerHesxQkdwvp
    %w(10 04.2015).each { |text| Word.create(text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-10']
  end

  it 'filters number combinations with too many digits' do
    Word.create(text: '2.5617.96')

    dates = DateDetector.filter
    expect(dates).to be_empty
  end

  it 'detects dates in compound words' do
    Word.create(text: 'Lief.dat.:13.04.15')

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-13']
  end

  it 'ignores non-dates' do
    Word.create(text: 'Lief.dat.:')

    dates = DateDetector.filter
    expect(dates).to be_empty
  end

  it 'detects full German dates' do
    %w(Wien, 23. April 2015 POMA).each { |text| Word.create(text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-23']
  end

  it 'does not recognize a number out of a date range', :focus do
    Word.create(text: '41.14.122')

    dates = DateDetector.filter
    expect(dates).to be_empty
  end

  it 'recognizes a long English date' do
    %w(09 March 2016).map { |text| Word.create(text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-09']
  end

  def date_strings(date_terms)
    date_terms.map { |date_term| date_term.to_datetime.strftime('%Y-%m-%d') }
  end
end
