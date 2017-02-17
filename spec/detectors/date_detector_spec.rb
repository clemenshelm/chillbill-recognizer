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
    # from bill CuJiDWLneTaSFin4P
    create_following_words(%w(3. Oktober 2016))
    dates = DateDetector.filter
    expect(date_strings(dates))
      .to eq %w(2015-04-23 2016-03-11 2015-12-04 2016-09-01 2016-10-03)
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

  it 'detects date format yyyy/mm/yy' do
    # from bill SaJwGfhgFR6FxCoxe
    create(
      :word,
      text: 'Datum:',
      left: 0.4787303664921466,
      right: 0.6217277486910995,
      top: 0.34183874786268575,
      bottom: 0.3597264237800868
    )

    create(
      :word,
      text: '2016/12/14',
      left: 0.6613219895287958,
      right: 0.9234293193717278,
      top: 0.3332894909903985,
      bottom: 0.3559121399447586
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-12-14']
  end

  it 'detects date without time' do
    # From 6qsXsgdKapRAhiS9b.pdf
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

  it 'does not detect other numbers as super future dates' do
    # From Sqc9ixBz4g8mDCdJK.pdf
    create(
      :word,
      text: '0211-20160901-01-4844',
      left: 0.149869109947644,
      right: 0.5981675392670157,
      top: 0.6031074835283705,
      bottom: 0.6171698298751106
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'does not detect short period super future dates' do
    # From FsZPCR9omH4SAvJ7m.pdf
    create(
      :word,
      text: '25.1',
      left: 0.10598626104023552,
      right: 0.1377167157343801,
      top: 0.6734505087881592,
      bottom: 0.6836262719703978
    )

    create(
      :word,
      text: '1.2816',
      left: 0.14327772325809618,
      right: 0.1959437356885836,
      top: 0.6729879740980573,
      bottom: 0.6833950046253469
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'does not detect long hungarian super future dates' do
    # From 3KdmxTXLCTMdyeduw.pdf
    create(
      :word,
      text: 'l111115153115.11.15',
      left: 0.0,
      right: 0.12401832460732984,
      top: 0.13058578374623755,
      bottom: 0.1535077564250984
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it "doesn't detect the end of an invoice number as part of the date" do
    create(
      :word,
      text: '8640-7737-7976-1846',
      left: 0.6285994764397905,
      right: 0.7931937172774869,
      top: 0.23126734505087881,
      bottom: 0.23982423681776133
    )
    create(
      :word,
      text: 'May',
      left: 0.4342277486910995,
      right: 0.4656413612565445,
      top: 0.2643385753931545,
      bottom: 0.27520814061054577
    )
    create(
      :word,
      text: '1,',
      left: 0.4718586387434555,
      right: 0.4829842931937173,
      top: 0.2643385753931545,
      bottom: 0.27474560592044406
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it "doesn't detect a year that is too short" do
    create(
      :word,
      text: '30.',
      left: 0.5107913669064749,
      right: 0.5336821451929366,
      top: 0.18631530282015718,
      bottom: 0.19579288025889968
    )

    create(
      :word,
      text: 'September',
      left: 0.5405493786788751,
      right: 0.6324395029431,
      top: 0.18539066111881647,
      bottom: 0.19879796578825706
    )

    create(
      :word,
      text: '203',
      left: 0.6383257030739045,
      right: 0.6644865925441465,
      top: 0.18631530282015718,
      bottom: 0.19579288025889968
    )

    create(
      :word,
      text: '6',
      left: 0.6690647482014388,
      right: 0.6782210595160235,
      top: 0.18631530282015718,
      bottom: 0.19579288025889968
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'returns nil if the date is not correct' do
    # from bill pHD2HWtSA4sEFuvHS.pdf
    create(
      :word,
      text: '31.30',
      left: 0.7081151832460733,
      right: 0.8164267015706806,
      top: 0.4988910793494332,
      bottom: 0.5117052735337605
    )

    create(
      :word,
      text: '2.15',
      left: 0.20647905759162305,
      right: 0.2905759162303665,
      top: 0.5547067520946279,
      bottom: 0.5682602267126663
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'detects August' do
    # from bill JBopEY4wukRCb7Sjh.pdf
    create(
      :word,
      text: '29.',
      left: 0.4204842931937173,
      right: 0.4375,
      top: 0.17625058438522676,
      bottom: 0.182328190743338
    )

    create(
      :word,
      text: 'August',
      left: 0.44142670157068065,
      right: 0.48232984293193715,
      top: 0.17601683029453016,
      bottom: 0.1841982234689107
    )

    create(
      :word,
      text: '2016',
      left: 0.48592931937172773,
      right: 0.5137434554973822,
      top: 0.17625058438522676,
      bottom: 0.182328190743338
    )
    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-08-29']
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
