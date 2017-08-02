# frozen_string_literal: true
require_relative '../../lib/detectors/date_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe DateDetector do
  it 'finds short German dates' do
    # From bill m6jLaPhmWvuZZqSXy.pdf
    %w(9025 0650/004/133 04.04.2015 13133).each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 20)
    end

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-04']
  end

  it 'does finds dates connected to other words' do
    # From bill m6jLaPhmWvuZZqSXy.pdf
    create(:word, text: '04.04.2015/13132257')

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-04']
  end

  it 'detects multiple dates in a document' do
    # From bill 4f5mhL6zBb3cyny7n.pdf
    %w(01.04.2015 28.02.15 31.03.15 27.02.2015 16.03.15)
      .each { |text| create(:word, text: text) }

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq %w(2015-04-01 2015-02-28 2015-03-31
                                         2015-02-27 2015-03-16)
  end

  it 'detects dates spread over several words' do
    # From bill XYt8oerHesxQkdwvp.pdf
    create_following_words(%w(10 04.2015))

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2015-04-10']
  end

  it 'detects dates spread over several words with periods recognized' do
    # From bill a8sPrtNYneSzxram9.pdf
    create(
      :word,
      text: '22.1',
      left: 0.5448298429319371,
      right: 0.5683900523560209,
      top: 0.6417668825161887,
      bottom: 0.6498612395929695
    )

    create(
      :word,
      text: '1.2016',
      left: 0.5736256544502618,
      right: 0.6138743455497382,
      top: 0.6415356151711379,
      bottom: 0.6498612395929695
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-11-22']
  end

  it 'does not detect words with a horizontal gap as date' do
    # From bill gANywe3fjvx98iPp2.pdf
    create(
      :word,
      text: '2',
      left: 0.8982329842931938,
      right: 0.9168848167539267,
      top: 0.3379619739371929,
      bottom: 0.36210211493270666
    )

    create(
      :word,
      text: '1',
      left: 0.36714659685863876,
      right: 0.3763089005235602,
      top: 0.3751335184789575,
      bottom: 0.42127750480666526
    )

    create(
      :word,
      text: '1,99',
      left: 0.7297120418848168,
      right: 0.8105366492146597,
      top: 0.3762016663106174,
      bottom: 0.4283272804956206
    )

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
    # from bill CuJiDWLneTaSFin4P.pdf
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
      left: 0.7464005235602095,
      right: 0.768651832460733,
      top: 0.10407030527289547,
      bottom: 0.11147086031452359
    )

    create(
      :word,
      text: '1',
      left: 0.774869109947644,
      right: 0.7804319371727748,
      top: 0.10407030527289547,
      bottom: 0.11147086031452359
    )

    create(
      :word,
      text: '2675366',
      left: 0.7859947643979057,
      right: 0.8406413612565445,
      top: 0.10407030527289547,
      bottom: 0.11147086031452359
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'detects the date in the dd/mm/yyyy format' do
    # Label missing - needs dd/mm/yy
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
      text: 'Rechnungsdatum',
      left: 0.5969905135754007,
      right: 0.7026496565260059,
      top: 0.21188989127920427,
      bottom: 0.22183668748554244
    )

    create(
      :word,
      text: '08.04.2016',
      left: 0.8066732090284593,
      right: 0.8756951259404645,
      top: 0.21165857043719638,
      bottom: 0.21998612074947954
    )

    create(
      :word,
      text: '13.04.2016',
      left: 0.8079816813869807,
      right: 0.8756951259404645,
      top: 0.22576914179967614,
      bottom: 0.2340966921119593
    )

    create(
      :word,
      text: 'Ihre',
      left: 0.14622178606476938,
      right: 0.18253189401373895,
      top: 0.3224612537589637,
      bottom: 0.33541522091140413
    )

    create(
      :word,
      text: '01.03.2016',
      left: 0.27347072293097807,
      right: 0.34249263984298334,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-04-08', '2016-04-13', '2016-03-01']
  end

  it 'detects Februar' do
    # From vGmK76dSSMrLQ8axN.pdf
    create(
      :word,
      text: '27.',
      left: 0.725130890052356,
      right: 0.75032722513089,
      top: 0.28330249768732657,
      bottom: 0.29324699352451433
    )

    create(
      :word,
      text: 'Februar',
      left: 0.7598167539267016,
      right: 0.8285340314136126,
      top: 0.28330249768732657,
      bottom: 0.29347826086956524
    )

    create(
      :word,
      text: '2017',
      left: 0.8347513089005235,
      right: 0.8782722513089005,
      top: 0.28330249768732657,
      bottom: 0.29347826086956524
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2017-02-27']
  end

  it 'detects October' do
    # From m4F2bLmpKn7wPqM7q.pdf

    create(
      :word,
      text: '27',
      left: 0.04155759162303665,
      right: 0.0549738219895288,
      top: 0.650555041628122,
      bottom: 0.6572617946345976
    )

    create(
      :word,
      text: 'October',
      left: 0.05988219895287958,
      right: 0.10602094240837696,
      top: 0.650555041628122,
      bottom: 0.6572617946345976
    )

    create(
      :word,
      text: '2016',
      left: 0.10962041884816753,
      right: 0.13776178010471204,
      top: 0.650555041628122,
      bottom: 0.6572617946345976
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-10-27']
  end

  it 'detects a date in the format yyyy.mm.dd ' do
    # From bsg8XJqLBJSt2dXeH.pdf
    create(
      :word,
      text: '2016.10.01.',
      left: 0.8229712041884817,
      right: 0.893324607329843,
      top: 0.1681313598519889,
      bottom: 0.17483811285846437
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-10-01']
  end

  it 'detects dd-mm-yyyy format' do
    # From mMHiT2b3C5fgYqBzY.pdf

    create(
      :word,
      text: '30-09-2016',
      left: 0.7460732984293194,
      right: 0.8232984293193717,
      top: 0.22422978920546677,
      bottom: 0.2323372712531851
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-09-30']
  end

  it 'detects short english date' do
    # From 8XJegsB4tn8XRuZpp.pdf
    create(
      :word,
      text: '03-Oct-2016',
      left: 0.7964659685863874,
      right: 0.8769633507853403,
      top: 0.13899167437557816,
      bottom: 0.14685476410730805
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-10-03']
  end

  it 'detects date format yyyy/mm/dd' do
    # Missing Label - needs yyyy/mm/dd
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
      left: 0.7087696335078534,
      right: 0.7607984293193717,
      top: 0.1769195189639223,
      bottom: 0.18293246993524515
    )

    create(
      :word,
      text: '09:40:02',
      left: 0.7640706806282722,
      right: 0.8043193717277487,
      top: 0.1769195189639223,
      bottom: 0.18293246993524515
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-11-04']
  end

  it 'does not detect other numbers as super future dates' do
    # From Sqc9ixBz4g8mDCdJK.pdf
    create(
      :word,
      text: '0211-20150901-01-4844',
      left: 0.24345549738219896,
      right: 0.6904450261780105,
      top: 0.6584718261382634,
      bottom: 0.67214082013964
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'does not detect short period super future dates' do
    # From FsZPCR9omH4SAvJ7m.pdf
    create(
      :word,
      text: '25.12.2816',
      left: 0.10794896957801767,
      right: 0.19757932613673537,
      top: 0.6757631822386679,
      bottom: 0.6864014801110083
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it "doesn't detect the end of an invoice number as part of the date" do
    # Label Missing - needs invoice number followed by short english date
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

  it 'returns nil if the date is not correct' do
    # from bill pHD2HWtSA4sEFuvHS.pdf
    create(
      :word,
      text: '31.',
      left: 0.7676701570680629,
      right: 0.824607329842932,
      top: 0.5165105963528832,
      bottom: 0.5292015771315919
    )

    create(
      :word,
      text: '30',
      left: 0.8350785340314136,
      right: 0.8759816753926701,
      top: 0.5166338097585017,
      bottom: 0.5293247905372105
    )

    create(
      :word,
      text: '2.15',
      left: 0.2660340314136126,
      right: 0.35013089005235604,
      top: 0.5723262690980778,
      bottom: 0.5858797437161163
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to be_empty
  end

  it 'detects a date in August, in the format "Month Day, Year"' do
    # From D9KKkDdhbd2JzaS2C.pdf
    create(
      :word,
      text: 'August',
      left: 0.618782722513089,
      right: 0.669175392670157,
      top: 0.26780758556891765,
      bottom: 0.2772895467160037
    )

    create(
      :word,
      text: '27,',
      left: 0.6740837696335078,
      right: 0.6927356020942408,
      top: 0.26780758556891765,
      bottom: 0.27682701202590193
    )

    create(
      :word,
      text: '2016',
      left: 0.6986256544502618,
      right: 0.7300392670157068,
      top: 0.26780758556891765,
      bottom: 0.27520814061054577
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-08-27']
  end

  it 'detects short english dates in July' do
    # From EmLuXAosrf54a9vnE.pdf
    create(
      :word,
      text: '1',
      left: 0.12467277486910995,
      right: 0.13154450261780104,
      top: 0.5923115832068792,
      bottom: 0.6009104704097117
    )

    create(
      :word,
      text: 'Jul',
      left: 0.13612565445026178,
      right: 0.15477748691099477,
      top: 0.5915528578654528,
      bottom: 0.6011633788568538
    )

    create(
      :word,
      text: '2016',
      left: 0.1606675392670157,
      right: 0.1950261780104712,
      top: 0.592058674759737,
      bottom: 0.6011633788568538
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-07-01']
  end

  it 'detects a slash term in the format mm/dd/yyyy' do
    # From KCsWbyeAvH7RMi2hL.pdf
    create(
      :word,
      text: '09/17/2013',
      left: 0.14066077854105333,
      right: 0.21524370297677461,
      top: 0.6426092990978487,
      bottom: 0.650705528568124
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2013-09-17']
  end

  it 'detects August' do
    # from bill JBopEY4wukRCb7Sjh.pdf
    create(
      :word,
      text: '29.',
      left: 0.4201570680628272,
      right: 0.43717277486910994,
      top: 0.3574100046750818,
      bottom: 0.3634876110331931
    )

    create(
      :word,
      text: 'August',
      left: 0.4407722513089005,
      right: 0.48200261780104714,
      top: 0.35717625058438524,
      bottom: 0.3653576437587658
    )

    create(
      :word,
      text: '2016',
      left: 0.48592931937172773,
      right: 0.5130890052356021,
      top: 0.3574100046750818,
      bottom: 0.3634876110331931
    )
    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2016-08-29']
  end

  it 'detects multi word dates first, and does not detect non dates' do
    # From vGmK76dSSMrLQ8axN.pdf
    create(
      :word,
      text: '27.',
      left: 0.725130890052356,
      right: 0.75032722513089,
      top: 0.28330249768732657,
      bottom: 0.29324699352451433
    )

    create(
      :word,
      text: 'Februar',
      left: 0.7598167539267016,
      right: 0.8285340314136126,
      top: 0.28330249768732657,
      bottom: 0.29347826086956524
    )

    create(
      :word,
      text: '2017',
      left: 0.8347513089005235,
      right: 0.8782722513089005,
      top: 0.28330249768732657,
      bottom: 0.29347826086956524
    )

    create(
      :word,
      text: '51/5/38',
      left: 0.6479057591623036,
      right: 0.6881544502617801,
      top: 0.0786308973172988,
      bottom: 0.08487511563367253
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2017-02-27']
  end

  it 'does not recognize long numbers as dates' do
    # from bill oAE4BBMHfDGfwhX3i.pdf

    create(
      :word,
      text: '902308630217',
      left: 0.7814851161269218,
      right: 0.8756951259404645,
      top: 0.19731667823270876,
      bottom: 0.2056442285449919
    )

    create(
      :word,
      text: '07.02.2017',
      left: 0.8066732090284593,
      right: 0.8756951259404645,
      top: 0.21165857043719638,
      bottom: 0.21998612074947954
    )

    create(
      :word,
      text: '15.02.2017',
      left: 0.8079816813869807,
      right: 0.8756951259404645,
      top: 0.22576914179967614,
      bottom: 0.2340966921119593
    )

    dates = DateDetector.filter
    expect(date_strings(dates)).to eq ['2017-02-07', '2017-02-15']
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
