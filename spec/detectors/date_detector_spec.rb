require_relative '../../lib/detectors/date_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe DateDetector do
  before(:each) do
    Word.dataset.delete
    PriceTerm.dataset.delete
    BillingPeriodTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete
    CurrencyTerm.dataset.delete
  end

  it 'finds short German dates' do
    # From bill m6jLaPhmWvuZZqSXy
    %w(9025 0650/004/133 04.04.2015 13133).each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 20)
    end

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-04']
  end

  it 'does finds dates connected to other words' do
    # From bill m6jLaPhmWvuZZqSXy
    create(:word, text: '04.04.2015/13132257')

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-04']
  end

  it 'detects multiple dates in a document' do
    # From bill 4f5mhL6zBb3cyny7n
    %w(01.04.2015 28.02.15 31.03.15 27.02.2015 16.03.15)
      .each { |text| create(:word, text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq %w(2015-04-01 2015-02-28 2015-03-31
      2015-02-27 2015-03-16)
  end

  it 'detects dates spread over several words' do
    # From bill XYt8oerHesxQkdwvp
    create_following_words(%w(10 04.2015))

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-10']
  end

  it 'does not detect words as date with too much space in between' do
    # From bill gANywe3fjvx98iPp2
    # Horizontal gap
    create(:word, text: 1, left: 1098, right: 1128, top: 1715, bottom: 1929)
    create(:word, text: 9, left: 2187, right: 2292, top: 1719, bottom: 1961)
    create(:word, text: 99, left: 2311, right: 2432, top: 1721, bottom: 1934)

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'filters number combinations with too many digits' do
    create(:word, text: '2.5617.96')

    dates = DateDetector.filter
    expect(dates).to be_empty
  end

  it 'detects dates in compound words' do
    create(:word, text: 'Lief.dat.:13.04.15')

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-13']
  end

  it 'ignores non-dates' do
    create(:word, text: 'Lief.dat.:')

    dates = DateDetector.filter
    expect(dates).to be_empty
  end

  it 'detects full German dates' do
    create_following_words(%w(Wien, 23. April 2015))
    create_following_words(%w(11. März 2016))
    create_following_words(%w(Freitag, 4. Dezember 2015))

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq %w(2015-04-23 2016-03-11 2015-12-04)
  end

  it 'does not recognize a number out of a date range' do
    %w(41.14.122).map { |text| create(:word, text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'recognizes a long English date' do
    create_following_words(%w(09 March 2016))

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-09']
  end

  it 'recognizes a short date with slashes as separators' do
    %w(1/03/16).map { |text| create(:word, text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-01']
  end

  it 'keeps the natural word order' do
    create_following_words(%w(09 March 2016))
    create(:word, text: '1/03/16')
    create_following_words(%w(09 March 2016))

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq %w(2016-03-09 2016-03-01 2016-03-09)
  end

  it 'does not recognize phone numbers as dates' do
    # From bill 7Nvce6pPniK3BCCA7
    create(:word, text: '+43', left: 2018, right: 2087, top: 223, bottom: 257)
    create(:word, text: '1', left: 2103, right: 2121, top: 223, bottom: 256)
    create(:word, text: '2675366', left: 2137, right: 2303, top: 223, bottom: 257)

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it "detects the date in the dd/mm/yy format" do
    create(:word, text: '7385622', left: 201, right: 340, top: 1396, bottom: 1426)
    create(:word, text: '3670800', left: 480, right: 619, top: 1397, bottom: 1427)
    create(:word, text: '1/03/16', left: 779, right: 895, top: 1397, bottom: 1427)
    create(:word, text: 'lNTERNET', left: 1065, right: 1259, top: 1397, bottom: 1426)
    create(:word, text: 'BO', left: 1312, right: 1367, top: 1397, bottom: 1426)

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-01']
  end

  it "detects multiple dates on a bill" do
    create(:word, text: 'Datum', left: 1613, right: 1732, top: 497, bottom: 529)
    create(:word, text: '16.03.2016', left: 1819, right: 2026, top: 498, bottom: 529)
    create(:word, text: '5020', left: 352, right: 444, top: 531, bottom: 563)
    create(:word, text: 'Salzburg', left: 459, right: 623, top: 530, bottom: 572)
    create(:word, text: 'Fällig', left: 1636, right: 1732, top: 585, bottom: 626)
    create(:word, text: '21.03.2016', left: 1816, right: 2026, top: 586, bottom: 618)
    create(:word, text: 'Rechnung', left: 2, right: 190, top: 752, bottom: 793)

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ["2016-03-16", "2016-03-21"]
  end

  def date_strings(date_terms)
    date_terms.map { |date_term| date_term.to_datetime.strftime('%Y-%m-%d') }
  end

  # TODO: Move to general helpers
  def create_following_words(texts)
    texts.each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 90)
    end
  end
end
