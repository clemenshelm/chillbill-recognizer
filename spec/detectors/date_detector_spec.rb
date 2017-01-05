# frozen_string_literal: true
require_relative '../../lib/detectors/date_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe DateDetector do
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

  it 'detects dates spread over several words with periods recognized' do
    # From bill a8sPrtNYneSzxram9
    create(
      :word,
      text: '22.1',
      left: 0.7833769633507853,
      right: 0.8069371727748691,
      top: 0.2835337650323774,
      bottom: 0.2918593894542091
    )

    create(
      :word,
      text: '1.2016',
      left: 0.8125,
      right: 0.8524214659685864,
      top: 0.2835337650323774,
      bottom: 0.29162812210915817
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-11-22']
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
    create_following_words(%w(Wien 23. April 2015))
    create_following_words(%w(11. März 2016))
    create_following_words(%w(Freitag 4. Dezember 2015))
    # from bill yiaGswKDskiLNkafN.pdf
    create_following_words(%w(01. September 2016))

    dates = DateDetector.filter
    expect(date_strings(dates))
      .to eq %w(2015-04-23 2016-03-11 2015-12-04 2016-09-01)
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
    create(:word, text: '15/06/2015')
    create_following_words(%w(09 March 2016))

    word_order = %w(2016-03-09 2016-03-01 2015-06-15 2016-03-09)
    dates = DateDetector.filter
    expect(date_strings(dates)).to eq word_order
  end

  it 'does not recognize phone numbers as dates' do
    # From bill 7Nvce6pPniK3BCCA7
    create(
      :word,
      text: '+43',
      left: 2018,
      right: 2087,
      top: 223,
      bottom: 257
    )

    create(
      :word,
      text: '1',
      left: 2103,
      right: 2121,
      top: 223,
      bottom: 256
    )

    create(
      :word,
      text: '2675366',
      left: 2137,
      right: 2303,
      top: 223,
      bottom: 257
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'detects the date in the dd/mm/yy format' do
    create(
      :word,
      text: '7385622',
      left: 201,
      right: 340,
      top: 1396,
      bottom: 1426
    )

    create(
      :word,
      text: '3670800',
      left: 480,
      right: 619,
      top: 1397,
      bottom: 1427
    )
    create(
      :word,
      text: '1/03/16',
      left: 779,
      right: 895,
      top: 1397,
      bottom: 1427
    )

    create(
      :word,
      text: 'lNTERNET',
      left: 1065,
      right: 1259,
      top: 1397,
      bottom: 1426
    )

    create(
      :word,
      text: 'BO',
      left: 1312,
      right: 1367,
      top: 1397,
      bottom: 1426
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-01']
  end

  it 'detects the date in the dd/mm/yyyy format' do
    create(
      :word,
      text: '7385622',
      left: 201,
      right: 340,
      top: 1396,
      bottom: 1426
    )

    create(
      :word,
      text: '3670800',
      left: 480,
      right: 619,
      top: 1397,
      bottom: 1427
    )

    create(
      :word,
      text: '12/03/2016',
      left: 779,
      right: 895,
      top: 1397,
      bottom: 1427
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-12']
  end

  it 'detects multiple dates on a bill' do
    create(
      :word,
      text: 'Datum',
      left: 1613,
      right: 1732,
      top: 497,
      bottom: 529
    )

    create(
      :word,
      text: '16.03.2016',
      left: 1819,
      right: 2026,
      top: 498,
      bottom: 529
    )

    create(
      :word,
      text: '5020',
      left: 352,
      right: 444,
      top: 531,
      bottom: 563
    )

    create(
      :word,
      text: 'Salzburg',
      left: 459,
      right: 623,
      top: 530,
      bottom: 572
    )

    create(
      :word,
      text: 'Fällig',
      left: 1636,
      right: 1732,
      top: 585,
      bottom: 626
    )

    create(
      :word,
      text: '21.03.2016',
      left: 1816,
      right: 2026,
      top: 586,
      bottom: 618
    )

    create(
      :word,
      text: 'Rechnung',
      left: 2,
      right: 190,
      top: 752,
      bottom: 793
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-03-16', '2016-03-21']
  end

  it 'detects October' do
    # From m4F2bLmpKn7wPqM7q.pdf

    create(
      :word,
      text: '27',
      left: 0.0003333333333333333,
      right: 0.014,
      top: 0.5585394581861013,
      bottom: 0.5656065959952886
    )

    create(
      :word,
      text: 'October',
      left: 0.018666666666666668,
      right: 0.06533333333333333,
      top: 0.5587750294464076,
      bottom: 0.5656065959952886
    )

    create(
      :word,
      text: '2016',
      left: 0.06833333333333333,
      right: 0.09666666666666666,
      top: 0.5585394581861013,
      bottom: 0.5656065959952886
    )
    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-10-27']
  end

  it 'detects yyyy.mm.dd regex' do
    # From bsg8XJqLBJSt2dXeH.pdf
    create(
      :word,
      text: '2016.10.01',
      left: 0.8226666666666667,
      right: 0.893,
      top: 0.1608951707891637,
      bottom: 0.16772673733804475
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-10-01']
  end

  it 'detects dd-mm-yyyy format' do
    # From mMHiT2b3C5fgYqBzY.pdf

    create(
      :word,
      text: '30-09-2016',
      left: 0.0003333333333333333,
      right: 0.014,
      top: 0.5585394581861013,
      bottom: 0.5656065959952886
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-09-30']
  end

  it 'detects short english date' do
    # From 8XJegsB4tn8XRuZpp.pdf
    create(
      :word,
      text: '03-Oct-2016',
      left: 0.7594895287958116,
      right: 0.8403141361256544,
      top: 0.06452358926919519,
      bottom: 0.07238667900092507
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-10-03']
  end

  it 'detects date without time' do
    # From bsg8XJqLBJSt2dXeH.pdf
    create(
      :word,
      text: '2016.11.04',
      left: 0.8226666666666667,
      right: 0.893,
      top: 0.1608951707891637,
      bottom: 0.16772673733804475
    )

    create(
      :word,
      text: '09:40:02',
      left: 0.8226666666666667,
      right: 0.893,
      top: 0.1608951707891637,
      bottom: 0.16772673733804475
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-11-04']
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
