# frozen_string_literal: true
require_relative '../../lib/detectors/price_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe PriceDetector do
  it 'finds prices separated with a comma' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    %w(C 14,49 4006972047414 2,69).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(14,49 2,69)
  end

  it "doesn't find words that contain no numbers" do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    %w(/,v„ Sie).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices).to be_empty
  end

  it "doesn't find words with 4 decimal places" do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(:word, text: '5,1920')

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'finds prices that consist of 2 words' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create_following_words(['54,', '00'])

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(54,00)
  end

  it 'finds prices that consist of 3 words' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create_following_words(%w(45 , 00))

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(45,00)
  end

  it 'only find prices with typical characters' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    %w(02/2015 N24 1.185,00).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['1.185,00']
  end

  it "doesn't find prices that contain letters" do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    %w(12 x 0,95).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq %w(0,95)
  end

  it "includes a word's bounding box" do
    # From fP5Y5WXQGoF45YePr.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    price_texts = %w(10.00 27.20 1.35 1.50 27.34)
    price_texts.each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq price_texts
  end

  it "doesn't find dates as prices" do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    %w(28.02.15 31.03.15 29.12.15).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'recognizes correct prices with a period as thousand separator' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    %w(3.551,37 4.261,64).each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    price_strings = prices.map { |price| format('%.2f', price.to_d) }
    expect(price_strings).to eq ['3551.37', '4261.64']
  end

  it 'recognizes correct prices with a period as decimal separator' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    price_texts = %w(10.00 27.20 1.35 1.50 27.34)
    price_texts.each { |text| create(:word, text: text) }

    prices = PriceDetector.filter
    price_strings = prices.map { |price| format('%.2f', price.to_d) }
    expect(price_strings).to eq price_texts
  end

  it 'recognizes prices with leading euro symbol' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(:word, text: '€86.97')

    prices = PriceDetector.filter
    price_string = format('%.2f', prices.first.to_d)
    expect(price_string).to eq('86.97')
  end

  it 'recognizes a price with a dash as decimal places' do
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '1000,-',
      left: 0.95,
      right: 0.95,
      top: 0.95,
      bottom: 0.95
    )

    prices = PriceDetector.filter
    price_string = format('%.2f', prices.first.to_d)
    expect(price_string).to eq('1000.00')
  end

  it 'finds a price without decimal places with the currency name behind' do
    # Missing Label - needs price without decimal places following currency name
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)
    create(
      :word,
      text: '11',
      left: 0.5734380111220151,
      right: 0.58717697088649,
      top: 0.5505823247316739,
      bottom: 0.5613153688056634
    )

    create(
      :word,
      text: '038',
      left: 0.5966633954857704,
      right: 0.6185803074910042,
      top: 0.5505823247316739,
      bottom: 0.5608586435259192
    )

    create(
      :word,
      text: 'Ft',
      left: 0.6277396140006543,
      right: 0.6411514556754988,
      top: 0.5505823247316739,
      bottom: 0.5608586435259192
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['11 038']
  end

  it 'detects price with comma and period separator' do
    # From bill fP5Y5WXQGoF45YePr.pdf

    # Dummy values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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

  it 'does not detect numbers before kg' do
    # From 25KA7rWWmhStXDEsb.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '28,80',
      left: 0.7719240837696335,
      right: 0.8053010471204188,
      top: 0.3172987974098057,
      bottom: 0.3251618871415356
    )

    create(
      :word,
      text: 'kg',
      left: 0.8095549738219895,
      right: 0.8232984293193717,
      top: 0.31706753006475485,
      bottom: 0.32562442183163737
    )

    create(
      :word,
      text: '4,24',
      left: 0.7797774869109948,
      right: 0.8049738219895288,
      top: 0.45351526364477335,
      bottom: 0.4616096207215541
    )

    create(
      :word,
      text: 'kg',
      left: 0.8095549738219895,
      right: 0.8232984293193717,
      top: 0.45351526364477335,
      bottom: 0.46207215541165586
    )

    create(
      :word,
      text: '3,76',
      left: 0.7797774869109948,
      right: 0.805628272251309,
      top: 0.4081868640148011,
      bottom: 0.4162812210915819
    )

    create(
      :word,
      text: 'kg',
      left: 0.8095549738219895,
      right: 0.8232984293193717,
      top: 0.4081868640148011,
      bottom: 0.4167437557816836
    )

    create(
      :word,
      text: '€',
      left: 0.05791884816753927,
      right: 0.06675392670157068,
      top: 0.8499074930619797,
      bottom: 0.8584643848288621
    )

    create(
      :word,
      text: '260,00',
      left: 0.07264397905759162,
      right: 0.12238219895287958,
      top: 0.8499074930619797,
      bottom: 0.8598519888991675
    )

    create(
      :word,
      text: '€',
      left: 0.2005890052356021,
      right: 0.2094240837696335,
      top: 0.8499074930619797,
      bottom: 0.8584643848288621
    )

    create(
      :word,
      text: '45,00',
      left: 0.21498691099476439,
      right: 0.25589005235602097,
      top: 0.8499074930619797,
      bottom: 0.8598519888991675
    )

    create(
      :word,
      text: '€',
      left: 0.3530759162303665,
      right: 0.3619109947643979,
      top: 0.8499074930619797,
      bottom: 0.8584643848288621
    )

    create(
      :word,
      text: '305,00',
      left: 0.36780104712041883,
      right: 0.4178664921465969,
      top: 0.8499074930619797,
      bottom: 0.8598519888991675
    )

    create(
      :word,
      text: '20',
      left: 0.4869109947643979,
      right: 0.5042539267015707,
      top: 0.8499074930619797,
      bottom: 0.8584643848288621
    )

    create(
      :word,
      text: '€',
      left: 0.5768979057591623,
      right: 0.5857329842931938,
      top: 0.8499074930619797,
      bottom: 0.8584643848288621
    )

    create(
      :word,
      text: '61,00',
      left: 0.5916230366492147,
      right: 0.6321989528795812,
      top: 0.8499074930619797,
      bottom: 0.8598519888991675
    )

    create(
      :word,
      text: '€',
      left: 0.7257853403141361,
      right: 0.7346204188481675,
      top: 0.8499074930619797,
      bottom: 0.8584643848288621
    )

    create(
      :word,
      text: '366,00',
      left: 0.7405104712041884,
      right: 0.7905759162303665,
      top: 0.8499074930619797,
      bottom: 0.8598519888991675
    )

    create(
      :word,
      text: '36,80',
      left: 0.7706151832460733,
      right: 0.8072643979057592,
      top: 0.8700277520814061,
      bottom: 0.8792784458834413
    )

    create(
      :word,
      text: 'kg',
      left: 0.8118455497382199,
      right: 0.8255890052356021,
      top: 0.8697964847363552,
      bottom: 0.8799722479185939
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['260,00', '45,00', '305,00', '61,00', '366,00']
  end

  it 'detects a price after EUR' do
    # From 2D6A3fe8Ggpovv3EF.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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
    # From 29pwjsKx88nhnQKm9.pdf
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
    # From 2D7BuHc3f8wAmb4y8.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

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

  it 'does not detect weights below the word kg as prices' do
    # From WmcA2uThGP5QaaciP.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: 'kg',
      left: 0.7480366492146597,
      right: 0.7673429319371727,
      top: 0.3856845031271717,
      bottom: 0.39587676627287466
    )

    create(
      :word,
      text: '123,00',
      left: 0.7081151832460733,
      right: 0.7653795811518325,
      top: 0.41463979615473706,
      bottom: 0.4232105628908965
    )

    prices = PriceDetector.filter
    expect(prices).to be_empty
  end

  it 'does not detect numbers below Anz.' do
    # From ihfDXTa64yYbFLa6Y.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: 'Anz.',
      left: 0.1197252208047105,
      right: 0.1573438011122015,
      top: 0.475937066173068,
      bottom: 0.4854234150856085
    )

    create(
      :word,
      text: '32,00',
      left: 0.1122015047432123,
      right: 0.1573438011122015,
      top: 0.5016196205460435,
      bottom: 0.512494215640907
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect prices in a long weird word' do
    # from bill 2AQDJZ5Nrhva2Qhug.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: ',.:2,..-2-w-.2---2.....-242.206.-',
      left: 0.724476439790576,
      right: 0.9617146596858639,
      top: 0.9286209286209286,
      bottom: 0.9410949410949411
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect a telephone number as a hungarian price' do
    # From gNPBm9p7ttJJFgCdY.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '+43',
      left: 0.5116126921818777,
      right: 0.5322211318285901,
      top: 0.9275965764515383,
      bottom: 0.9343048808697664
    )

    create(
      :word,
      text: '660',
      left: 0.5377821393523062,
      right: 0.5583905789990187,
      top: 0.9275965764515383,
      bottom: 0.9343048808697664
    )

    create(
      :word,
      text: '76',
      left: 0.5639515865227347,
      right: 0.5773634281975794,
      top: 0.9275965764515383,
      bottom: 0.9343048808697664
    )

    create(
      :word,
      text: '75',
      left: 0.582597317631665,
      right: 0.5960091593065097,
      top: 0.9275965764515383,
      bottom: 0.9343048808697664
    )

    create(
      :word,
      text: '979',
      left: 0.6015701668302257,
      right: 0.6221786064769381,
      top: 0.9275965764515383,
      bottom: 0.9343048808697664
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect percent as price' do
    # From 2X3ybPNqDbuwH5dSX.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '5,66',
      left: 0.39299738219895286,
      right: 0.42408376963350786,
      top: 0.5289084181313598,
      bottom: 0.5388529139685476
    )

    create(
      :word,
      text: '%',
      left: 0.43030104712041883,
      right: 0.44404450261780104,
      top: 0.5289084181313598,
      bottom: 0.5374653098982424
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect hours as price' do
    # From 2tMo5XaJRTcPwG55r.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '0,25',
      left: 0.28221059516023544,
      right: 0.3132766514061478,
      top: 0.5105202312138728,
      bottom: 0.5204624277456648
    )

    create(
      :word,
      text: 'Stunden',
      left: 0.3194898626553303,
      right: 0.3829300196206671,
      top: 0.5102890173410405,
      bottom: 0.5193063583815029
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect multi units as prices' do
    # From KGEFGTvogD5Ly9jTT.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '30,00',
      left: 0.5173429319371727,
      right: 0.5543193717277487,
      top: 0.4663739311301132,
      bottom: 0.4758493182343425
    )

    create(
      :word,
      text: 'SK',
      left: 0.5608638743455497,
      right: 0.580824607329843,
      top: 0.4661428241275711,
      bottom: 0.47469378322163164
    )

    create(
      :word,
      text: '1,00',
      left: 0.5271596858638743,
      right: 0.5546465968586387,
      top: 0.5137508666512596,
      bottom: 0.5236884677605731
    )

    create(
      :word,
      text: 'PA',
      left: 0.5611910994764397,
      right: 0.581151832460733,
      top: 0.5137508666512596,
      bottom: 0.5220707187427779
    )

    create(
      :word,
      text: '40,00',
      left: 0.5160340314136126,
      right: 0.5536649214659686,
      top: 0.6089669516986365,
      bottom: 0.6184423388028657
    )

    create(
      :word,
      text: 'ST',
      left: 0.5602094240837696,
      right: 0.5795157068062827,
      top: 0.6089669516986365,
      bottom: 0.6170556967876126
    )

    create(
      :word,
      text: '10,00',
      left: 0.518324607329843,
      right: 0.5543193717277487,
      top: 0.5611278021724059,
      bottom: 0.5710654032817194
    )

    create(
      :word,
      text: 'SG',
      left: 0.5605366492146597,
      right: 0.5818062827225131,
      top: 0.5611278021724059,
      bottom: 0.5696787612664663
    )

    create(
      :word,
      text: '2.065,10',
      left: 0.724476439790576,
      right: 0.7833769633507853,
      top: 0.561358909174948,
      bottom: 0.5710654032817194
    )

    create(
      :word,
      text: 'TO',
      left: 0.7882853403141361,
      right: 0.8089005235602095,
      top: 0.561358909174948,
      bottom: 0.5694476542639242
    )

    create(
      :word,
      text: '1,57',
      left: 0.7542539267015707,
      right: 0.7820680628272252,
      top: 0.5139819736538017,
      bottom: 0.5232262537554888
    )

    create(
      :word,
      text: 'KG',
      left: 0.7882853403141361,
      right: 0.8089005235602095,
      top: 0.5135197596487173,
      bottom: 0.5220707187427779
    )

    create(
      :word,
      text: '310,93',
      left: 0.7372382198952879,
      right: 0.7830497382198953,
      top: 0.6089669516986365,
      bottom: 0.6184423388028657
    )

    create(
      :word,
      text: 'M3',
      left: 0.7889397905759162,
      right: 0.8089005235602095,
      top: 0.6089669516986365,
      bottom: 0.6170556967876126
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'detects price followed by an euro sign only once' do
    # From 2o8P5wJy9pTYaEbLo.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '2,17€',
      left: 0.7804319371727748,
      right: 0.8213350785340314,
      top: 0.5407030527289547,
      bottom: 0.5499537465309898
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['2,17€']
  end

  it 'detects the correct price regex' do
    # From BYnCDzw7nNMFergRW.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '€247,28',
      left: 0.8632198952879581,
      right: 0.918520942408377,
      top: 0.36262719703977797,
      bottom: 0.3723404255319149
    )

    prices = PriceDetector.filter
    expect(prices.map(&:regex)).to eq [PriceDetector::DECIMAL_PRICE_REGEX.to_s]
  end

  it 'detects prices which are not in part of a quantity' do
    # From rDxLnivxoXQw9nWa7.pdf
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: 'Menge',
      left: 0.5785340314136126,
      right: 0.6285994764397905,
      top: 0.4225254394079556,
      bottom: 0.4333950046253469
    )

    create(
      :word,
      text: '1,00',
      left: 0.5971858638743456,
      right: 0.6236910994764397,
      top: 0.5074005550416282,
      bottom: 0.5164199814986123
    )

    create(
      :word,
      text: '1,00',
      left: 0.5971858638743456,
      right: 0.6236910994764397,
      top: 0.5208140610545791,
      bottom: 0.5298334875115633
    )

    create(
      :word,
      text: '5,00',
      left: 0.6855366492146597,
      right: 0.7136780104712042,
      top: 0.5208140610545791,
      bottom: 0.5298334875115633
    )

    create(
      :word,
      text: '431,25',
      left: 0.09325916230366492,
      right: 0.1387434554973822,
      top: 0.8237742830712304,
      bottom: 0.8327937095282146
    )

    create(
      :word,
      text: '86,25',
      left: 0.21171465968586387,
      right: 0.24803664921465968,
      top: 0.8237742830712304,
      bottom: 0.8327937095282146
    )

    create(
      :word,
      text: '517,50',
      left: 0.837696335078534,
      right: 0.8828534031413613,
      top: 0.8237742830712304,
      bottom: 0.8327937095282146
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to eq ['5,00', '431,25', '86,25', '517,50']
  end

  it 'does not detect MWST as price' do
    # From C5sri9hxpbDhha68D.png
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '21,41',
      left: 0.44945054945054946,
      right: 0.5406593406593406,
      top: 0.5265,
      bottom: 0.542
    )

    create(
      :word,
      text: 'MWST',
      left: 0.5648351648351648,
      right: 0.6362637362637362,
      top: 0.5265,
      bottom: 0.54
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  it 'does not detect date as price' do
    # From C5sri9hxpbDhha68D.png
    # Dummy dimension values for the bill
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '10',
      left: 0.521978021978022,
      right: 0.5560439560439561,
      top: 0.724,
      bottom: 0.737
    )

    create(
      :word,
      text: '.',
      left: 0.5659340659340659,
      right: 0.5692307692307692,
      top: 0.735,
      bottom: 0.737
    )

    create(
      :word,
      text: '05',
      left: 0.578021978021978,
      right: 0.6131868131868132,
      top: 0.724,
      bottom: 0.737
    )

    create(
      :word,
      text: '.',
      left: 0.6230769230769231,
      right: 0.6263736263736264,
      top: 0.735,
      bottom: 0.737
    )

    create(
      :word,
      text: '17',
      left: 0.6373626373626373,
      right: 0.6703296703296703,
      top: 0.724,
      bottom: 0.7375
    )

    prices = PriceDetector.filter
    expect(prices.map(&:text)).to be_empty
  end

  # TODO: Move to general helpers
  def create_following_words(texts)
    texts.each_with_index do |text, index|
      left = index * 100
      create(:word, text: text, left: left, right: left + 90)
    end
  end
end
