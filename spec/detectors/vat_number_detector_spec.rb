# frozen_string_literal: true
require_relative '../../lib/detectors/vat_number_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe VatNumberDetector do
  it 'returns an empty dataset if there are no words' do
    # From PYdefyzCHkSp9atMY.jpg
    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq []
  end

  it 'recognizes an Austrian VAT ID number seperated by a space' do
    # From 2BF2icKytY8bvPGwR.pdf
    create(
      :word,
      text: 'ATU',
      left: 0.44862565445026176,
      right: 0.4849476439790576,
      top: 0.15703052728954672,
      bottom: 0.17067530064754857
    )

    create(
      :word,
      text: '37893801',
      left: 0.5,
      right: 0.5978403141361257,
      top: 0.15656799259944496,
      bottom: 0.1704440333024977
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end

  it 'recognizes an EU VAT ID number' do
    # From 2Q7v8DGnTnYQkBBhA.pdf
    create(
      :word,
      text: 'Number:',
      left: 0.7915575916230366,
      right: 0.8530759162303665,
      top: 0.08487511563367253,
      bottom: 0.09343200740055504
    )

    create(
      :word,
      text: 'EU372001951',
      left: 0.8606020942408377,
      right: 0.9633507853403142,
      top: 0.08487511563367253,
      bottom: 0.09366327474560592
    )

    create(
      :word,
      text: 'summary',
      left: 0.060536649214659684,
      right: 0.21106020942408377,
      top: 0.11193339500462535,
      bottom: 0.13390379278445882
    )

    create(
      :word,
      text: 'Invoice',
      left: 0.5340314136125655,
      right: 0.5899869109947644,
      top: 0.11308973172987974,
      bottom: 0.12164662349676225
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['EU372001951']
  end

  it 'recognizes a Luxemburg VAT ID number' do
    # From 2CxjCYS58hNhLqXYH.pdf
    create(
      :word,
      text: 'LU20260743',
      left: 0.7814851161269218,
      right: 0.8393850179914949,
      top: 0.6062919269026139,
      bottom: 0.611149664584779
    )

    create(
      :word,
      text: 'diesem',
      left: 0.7311089303238469,
      right: 0.7634936211972522,
      top: 0.5852417302798982,
      bottom: 0.5900994679620634
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['LU20260743']
  end

  it 'recognizes a German VAT ID number' do
    # From 2FSoeuJ6BMxRsGuPA.pdf
    create(
      :word,
      text: 'USt-ID',
      left: 0.4466623036649215,
      right: 0.4767670157068063,
      top: 0.6288159111933395,
      bottom: 0.633672525439408
    )

    create(
      :word,
      text: ':',
      left: 0.4826570680628272,
      right: 0.4836387434554974,
      top: 0.6302035152636448,
      bottom: 0.633672525439408
    )

    create(
      :word,
      text: 'DE814584193',
      left: 0.49018324607329844,
      right: 0.5549738219895288,
      top: 0.6288159111933395,
      bottom: 0.633672525439408
    )

    create(
      :word,
      text: 'LU-BIO-04',
      left: 0.47643979057591623,
      right: 0.525196335078534,
      top: 0.6371415356151712,
      bottom: 0.6419981498612396
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['DE814584193']
  end

  # This test has a large number of samples
  # so it can calculate a realistic median font height
  it 'recognizes Irish VAT ID number broken by a line break' do
    create(
      :word,
      text: 'Umsatzsteuer-Identitikationsnummer:',
      left: 1821,
      right: 2483,
      top: 368,
      bottom: 398
    )

    create(
      :word,
      text: 'IE',
      left: 2500,
      right: 2534,
      top: 368,
      bottom: 398
    )

    create(
      :word,
      text: 'Rec',
      left: 7,
      right: 181,
      top: 362,
      bottom: 437
    )

    create(
      :word,
      text: 'h',
      left: 191,
      right: 239,
      top: 362,
      bottom: 435
    )

    create(
      :word,
      text: 'n',
      left: 253,
      right: 301,
      top: 380,
      bottom: 435
    )

    create(
      :word,
      text: 'u',
      left: 314,
      right: 362,
      top: 382,
      bottom: 437
    )

    create(
      :word,
      text: 'I1',
      left: 376,
      right: 424,
      top: 380,
      bottom: 435
    )

    create(
      :word,
      text: '9',
      left: 434,
      right: 486,
      top: 380,
      bottom: 457
    )

    create(
      :word,
      text: '6388047V',
      left: 1819,
      right: 2003,
      top: 417,
      bottom: 446
    )

    create(
      :word,
      text: 'Rechnungsempfänger',
      left: 3,
      right: 533,
      top: 628,
      bottom: 675
    )

    create(
      :word,
      text: 'Rechnungsempfänger',
      left: 3,
      right: 533,
      top: 628,
      bottom: 675
    )

    create(
      :word,
      text: 'Details',
      left: 1302,
      right: 1462,
      top: 628,
      bottom: 665
    )

    create(
      :word,
      text: 'Clemens',
      left: 2,
      right: 196,
      top: 699,
      bottom: 736
    )

    create(
      :word,
      text: 'Helm',
      left: 216,
      right: 328,
      top: 699,
      bottom: 736
    )

    create(
      :word,
      text: 'Rechnungsnummer:',
      left: 1302,
      right: 1749,
      top: 699,
      bottom: 745
    )

    create(
      :word,
      text: '321923922866546-5',
      left: 1885,
      right: 2347,
      top: 699,
      bottom: 736
    )

    create(
      :word,
      text: 'ChillBiII',
      left: 2,
      right: 163,
      top: 770,
      bottom: 807
    )

    create(
      :word,
      text: 'Ausstellungsdatum:',
      left: 1298,
      right: 1735,
      top: 770,
      bottom: 817
    )

    create(
      :word,
      text: '30.11.2015',
      left: 1885,
      right: 2129,
      top: 770,
      bottom: 807
    )

    create(
      :word,
      text: 'Hietzinger',
      left: 3,
      right: 228,
      top: 840,
      bottom: 887
    )

    create(
      :word,
      text: 'Hauptstraße',
      left: 244,
      right: 516,
      top: 840,
      bottom: 887
    )

    create(
      :word,
      text: '99A/3',
      left: 533,
      right: 661,
      top: 840,
      bottom: 877
    )

    create(
      :word,
      text: 'Zahlungsbedingungen:',
      left: 1300,
      right: 1807,
      top: 840,
      bottom: 887
    )

    create(
      :word,
      text: 'Sofort',
      left: 1885,
      right: 2018,
      top: 840,
      bottom: 877
    )

    create(
      :word,
      text: 'fällig',
      left: 2033,
      right: 2132,
      top: 840,
      bottom: 887
    )

    create(
      :word,
      text: '1130',
      left: 5,
      right: 106,
      top: 910,
      bottom: 947
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['IE6388047V']
  end

  it 'recognizes a VAT ID number where number is larger font' do
    # From 2BF2icKytY8bvPGwR.pdf
    create(
      :word,
      text: 'ATU',
      left: 0.44862565445026176,
      right: 0.4849476439790576,
      top: 0.15703052728954672,
      bottom: 0.17067530064754857
    )

    create(
      :word,
      text: '37893801',
      left: 0.5,
      right: 0.5978403141361257,
      top: 0.15656799259944496,
      bottom: 0.1704440333024977
    )

    create(
      :word,
      text: 'zahlen',
      left: 0.27715968586387435,
      right: 0.3517670157068063,
      top: 0.341581868640148,
      bottom: 0.354995374653099
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end

  it 'ignores EUR with digits following' do
    # Label missing - needs EUR followed by digits
    create(
      :word,
      text: 'EUR',
      left: 0.2911350997710173,
      right: 0.31076218514883874,
      top: 0.684941013185288,
      bottom: 0.6914179967615082
    )

    create(
      :word,
      text: '101,13',
      left: 0.3274452077199869,
      right: 0.3680078508341511,
      top: 0.6842470506592644,
      bottom: 0.6930372426555632
    )

    create(
      :word,
      text: '17087073',
      left: 0.1318285901210337,
      right: 0.18776578344782466,
      top: 0.6983576220217441,
      bottom: 0.7057598889659958
    )

    create(
      :word,
      text: '072001',
      left: 0.19659797186784428,
      right: 0.23748773307163887,
      top: 0.6983576220217441,
      bottom: 0.7057598889659958
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq []
  end

  it 'recognizes a German VAT ID number broken by several spaces' do
    # From bill mqJFF5BbAgGSr4pqX
    create(
      :word,
      text: 'DE',
      left: 0.6230366492146597,
      right: 0.6364528795811518,
      top: 0.9314656170409817,
      bottom: 0.9370224589025238
    )

    create(
      :word,
      text: '147',
      left: 0.6416884816753927,
      right: 0.6577225130890052,
      top: 0.9314656170409817,
      bottom: 0.9370224589025238
    )

    create(
      :word,
      text: '645',
      left: 0.662630890052356,
      right: 0.6799738219895288,
      top: 0.9314656170409817,
      bottom: 0.9370224589025238
    )

    create(
      :word,
      text: '058',
      left: 0.6842277486910995,
      right: 0.7015706806282722,
      top: 0.9314656170409817,
      bottom: 0.9370224589025238
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['DE147645058']
  end

  it 'detects Austrian VAT ID number in lower case' do
    # From bill PkAZBBAXapKyNNuqt.pdf
    create(
      :word,
      text: 'atu',
      left: 0.5721295387634936,
      right: 0.5852142623487079,
      top: 0.9303724265556327,
      bottom: 0.9354614850798056
    )

    create(
      :word,
      text: '67318155',
      left: 0.5888125613346418,
      right: 0.6329735034347399,
      top: 0.9303724265556327,
      bottom: 0.9352301642377978
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU67318155']
  end

  # Large sample size due to median height factor
  it 'detects a VAT ID number using a larger median height' do
    # from bill KsWubxamfEAwc7CfT.pdf
    create(
      :word,
      text: 'Hamburg',
      left: 0.29842931937172773,
      right: 0.34522251308900526,
      top: 0.1801572617946346,
      bottom: 0.18848288621646622
    )

    create(
      :word,
      text: 'VINOVUM',
      left: 0.08147905759162304,
      right: 0.16230366492146597,
      top: 0.19703977798334876,
      bottom: 0.20652173913043478
    )

    create(
      :word,
      text: 'Weinhandel',
      left: 0.17048429319371727,
      right: 0.2663612565445026,
      top: 0.19611470860314523,
      bottom: 0.20605920444033302
    )

    create(
      :word,
      text: 'OG',
      left: 0.2745418848167539,
      right: 0.29842931937172773,
      top: 0.19611470860314523,
      bottom: 0.20559666975023128
    )

    create(
      :word,
      text: 'Inhaber:',
      left: 0.0824607329842932,
      right: 0.15281413612565445,
      top: 0.21114708603145235,
      bottom: 0.22086031452358926
    )

    create(
      :word,
      text: 'Nina',
      left: 0.162630890052356,
      right: 0.1979712041884817,
      top: 0.21137835337650324,
      bottom: 0.2206290471785384
    )

    create(
      :word,
      text: 'Tiefner',
      left: 0.20451570680628273,
      right: 0.26341623036649214,
      top: 0.21045328399629973,
      bottom: 0.22039777983348752
    )

    create(
      :word,
      text: 'UST-ID:',
      left: 0.08278795811518325,
      right: 0.14856020942408377,
      top: 0.2259481961147086,
      bottom: 0.23589269195189638
    )

    create(
      :word,
      text: 'ATU65315367',
      left: 0.15706806282722513,
      right: 0.275196335078534,
      top: 0.22525439407955597,
      bottom: 0.23566142460684553
    )

    create(
      :word,
      text: '/',
      left: 0.8475130890052356,
      right: 0.8668193717277487,
      top: 0.06174838112858464,
      bottom: 0.07493061979648474
    )

    create(
      :word,
      text: 'espresso',
      left: 0.7519633507853403,
      right: 0.8452225130890052,
      top: 0.08094357076780759,
      bottom: 0.09320074005550416
    )

    create(
      :word,
      text: 'prego',
      left: 0.8534031413612565,
      right: 0.9093586387434555,
      top: 0.08048103607770583,
      bottom: 0.0927382053654024
    )

    create(
      :word,
      text: '/',
      left: 0.8962696335078534,
      right: 0.9145942408376964,
      top: 0.09551341350601295,
      bottom: 0.10938945420906568
    )

    create(
      :word,
      text: 'Espresso-Prego',
      left: 0.8226439790575916,
      right: 0.9162303664921466,
      top: 0.12789084181313598,
      bottom: 0.13852913968547642
    )

    create(
      :word,
      text: 'lnhaber',
      left: 0.7778141361256544,
      right: 0.8216623036649214,
      top: 0.13922294172062905,
      bottom: 0.14754856614246067
    )

    create(
      :word,
      text: 'Georg',
      left: 0.8255890052356021,
      right: 0.8615837696335078,
      top: 0.13852913968547642,
      bottom: 0.1496299722479186
    )

    create(
      :word,
      text: 'Schwarz',
      left: 0.8664921465968587,
      right: 0.9165575916230366,
      top: 0.13852913968547642,
      bottom: 0.14708603145235893
    )

    create(
      :word,
      text: 'Peutestraße',
      left: 0.8183900523560209,
      right: 0.8893979057591623,
      top: 0.14939870490286772,
      bottom: 0.15795559666975023
    )

    create(
      :word,
      text: 'STB',
      left: 0.893651832460733,
      right: 0.9165575916230366,
      top: 0.14939870490286772,
      bottom: 0.15772432932469935
    )

    create(
      :word,
      text: '9',
      left: 0.8514397905759162,
      right: 0.8583115183246073,
      top: 0.16026827012025902,
      bottom: 0.16859389454209064
    )

    create(
      :word,
      text: 'Hamb',
      left: 0.8632198952879581,
      right: 0.8975785340314136,
      top: 0.16003700277520813,
      bottom: 0.1711378353376503
    )

    create(
      :word,
      text: 'rg',
      left: 0.9057591623036649,
      right: 0.9168848167539267,
      top: 0.16188714153561518,
      bottom: 0.17067530064754857
    )

    create(
      :word,
      text: 'Tel.',
      left: 0.794175392670157,
      right: 0.81282722513089,
      top: 0.17090656799259946,
      bottom: 0.17946345975948197
    )

    create(
      :word,
      text: '042%5778089l181',
      left: 0.8177356020942408,
      right: 0.9149214659685864,
      top: 0.1604995374653099,
      bottom: 0.17946345975948197
    )

    create(
      :word,
      text: 'Internet:',
      left: 0.7234947643979057,
      right: 0.7702879581151832,
      top: 0.1822386679000925,
      bottom: 0.19056429232192415
    )

    create(
      :word,
      text: 'www.espresso-prego.de',
      left: 0.7745418848167539,
      right: 0.9165575916230366,
      top: 0.18154486586493987,
      bottom: 0.19241443108233117
    )

    create(
      :word,
      text: 'E-Mail',
      left: 0.724803664921466,
      right: 0.7607984293193717,
      top: 0.19264569842738205,
      bottom: 0.20097132284921368
    )

    create(
      :word,
      text: 'hallo@espresso-',
      left: 0.7653795811518325,
      right: 0.8645287958115183,
      top: 0.19218316373728028,
      bottom: 0.2030527289546716
    )

    create(
      :word,
      text: 'regode',
      left: 0.8727094240837696,
      right: 0.9165575916230366,
      top: 0.19218316373728028,
      bottom: 0.20282146160962072
    )

    create(
      :word,
      text: 'Steuernummer:',
      left: 0.7414921465968587,
      right: 0.831479057591623,
      top: 0.2030527289546716,
      bottom: 0.211840888066605
    )

    create(
      :word,
      text: '43/2',
      left: 0.8360602094240838,
      right: 0.8615837696335078,
      top: 0.2030527289546716,
      bottom: 0.21137835337650324
    )

    create(
      :word,
      text: '5/01876',
      left: 0.8694371727748691,
      right: 0.9168848167539267,
      top: 0.20282146160962072,
      bottom: 0.21137835337650324
    )

    create(
      :word,
      text: 'Ust',
      left: 0.7892670157068062,
      right: 0.8079188481675392,
      top: 0.2141535615171138,
      bottom: 0.22294172062904719
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU65315367']
  end
end
