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
    create(
      :word,
      text: 'Wien',
      left: 411,
      right: 485,
      top: 267,
      bottom: 297
    )

    create(
      :word,
      text: 'ATU',
      left: 298,
      right: 352,
      top: 311,
      bottom: 341
    )

    create(
      :word,
      text: '37893801',
      left: 374,
      right: 521,
      top: 309,
      bottom: 340
    )

    create(
      :word,
      text: 'EUR',
      left: 732,
      right: 787,
      top: 352,
      bottom: 382
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end

  # Bill with two VATs, but this test works because of the data sample
  it 'recognizes an Austrian VAT ID number' do
    create(
      :word,
      text: 'Umsatzsteuer-Identifikotionsnummer:',
      left: 1487,
      right: 2118,
      top: 3849,
      bottom: 3882
    )

    create(
      :word,
      text: 'ATU19420008',
      left: 2130,
      right: 2386,
      top: 3850,
      bottom: 3882
    )

    create(
      :word,
      text: 'ARA',
      left: 2416,
      right: 2492,
      top: 3850,
      bottom: 3881
    )

    create(
      :word,
      text: '94647',
      left: 2503,
      right: 2615,
      top: 3850,
      bottom: 3882
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU19420008']
  end

  it 'recognizes an EU VAT ID number' do
    create(
      :word,
      text: 'Number:',
      left: 2272,
      right: 2458,
      top: 0,
      bottom: 36
    )

    create(
      :word,
      text: 'EU372001951',
      left: 2479,
      right: 2789,
      top: 0,
      bottom: 36
    )

    create(
      :word,
      text: 'summary',
      left: 79,
      right: 531,
      top: 112,
      bottom: 208
    )

    create(
      :word,
      text: 'Inv0Ice',
      left: 1501,
      right: 1669,
      top: 119,
      bottom: 156
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['EU372001951']
  end

  it 'recognizes a Luxemburg VAT ID number' do
    create(
      :word,
      text: 'Umsatzsteueridentifikationsnummer:',
      left: 1621,
      right: 2138,
      top: 2492,
      bottom: 2516
    )

    create(
      :word,
      text: 'LU20260743',
      left: 2157,
      right: 2331,
      top: 2494,
      bottom: 2516
    )

    create(
      :word,
      text: 'USt-ID',
      left: 1151,
      right: 1244,
      top: 2527,
      bottom: 2548
    )

    create(
      :word,
      text: ':',
      left: 1260,
      right: 1264,
      top: 2532,
      bottom: 2548
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['LU20260743']
  end

  it 'recognizes a German VAT ID number' do
    create(
      :word,
      text: 'USt-ID',
      left: 1227,
      right: 1335,
      top: 2793,
      bottom: 2820
    )

    create(
      :word,
      text: ':',
      left: 1353,
      right: 1357,
      top: 2800,
      bottom: 2819
    )

    create(
      :word,
      text: 'DE814584193',
      left: 1376,
      right: 1604,
      top: 2792,
      bottom: 2819
    )

    create(
      :word,
      text: 'LU-BlO-04',
      left: 1329,
      right: 1501,
      top: 2831,
      bottom: 2858
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
    create(
      :word,
      text: 'Wien',
      left: 2229,
      right: 2293,
      top: 301,
      bottom: 327
    )

    create(
      :word,
      text: 'ATU',
      left: 2130,
      right: 2177,
      top: 339,
      bottom: 363
    )

    create(
      :word,
      text: '37893801',
      left: 2196,
      right: 2323,
      top: 338,
      bottom: 365
    )

    create(
      :word,
      text: 'EUR',
      left: 2505,
      right: 2553,
      top: 379,
      bottom: 404
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end

  it 'ignores EUR with digits following' do
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
    # from bill mqJFF5BbAgGSr4pqX
    create(
      :word,
      text: 'DE',
      left: 0.5245418848167539,
      right: 0.5379581151832461,
      top: 0.8617735586941422,
      bottom: 0.8673304005556842
    )

    create(
      :word,
      text: '147',
      left: 0.5431937172774869,
      right: 0.5592277486910995,
      top: 0.8617735586941422,
      bottom: 0.8673304005556842
    )

    create(
      :word,
      text: '645',
      left: 0.5641361256544503,
      right: 0.581479057591623,
      top: 0.8617735586941422,
      bottom: 0.8673304005556842
    )

    create(
      :word,
      text: '058',
      left: 0.5857329842931938,
      right: 0.6030759162303665,
      top: 0.8617735586941422,
      bottom: 0.8673304005556842
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['DE147645058']
  end

  # Large sample size due to median height factor
  it 'detects a VAT ID number using a larger median height' do
    # from bill KsWubxamfEAwc7CfT.pdf
    create(
      :word,
      text: '*',
      left: 0.12238219895287958,
      right: 0.12467277486910995,
      top: 0.1343663274745606,
      bottom: 0.13598519888991675
    )

    create(
      :word,
      text: 'E-Mail',
      left: 0.649869109947644,
      right: 0.6858638743455497,
      top: 0.13020351526364476,
      bottom: 0.13852913968547642
    )

    create(
      :word,
      text: 'hallo@espresso-',
      left: 0.6904450261780105,
      right: 0.7895942408376964,
      top: 0.12974098057354302,
      bottom: 0.14061054579093432
    )

    create(
      :word,
      text: 'rego.de',
      left: 0.7977748691099477,
      right: 0.8416230366492147,
      top: 0.12974098057354302,
      bottom: 0.14037927844588344
    )

    create(
      :word,
      text: 'VINOVUM',
      left: 0.006544502617801047,
      right: 0.08736910994764398,
      top: 0.13459759481961148,
      bottom: 0.1440795559666975
    )

    create(
      :word,
      text: 'Wemhandd',
      left: 0.09554973821989529,
      right: 0.19142670157068062,
      top: 0.13367252543940797,
      bottom: 0.15032377428307123
    )

    create(
      :word,

      text: 'OG',
      left: 0.19960732984293195,
      right: 0.22349476439790575,
      top: 0.13367252543940797,
      bottom: 0.143154486586494
    )

    create(
      :word,
      text: 'Steuernummer:',
      left: 0.6665575916230366,
      right: 0.756544502617801,
      top: 0.14061054579093432,
      bottom: 0.14939870490286772
    )

    create(
      :word,
      text: '43/2',
      left: 0.7611256544502618,
      right: 0.7866492146596858,
      top: 0.14061054579093432,
      bottom: 0.14893617021276595
    )

    create(
      :word,
      text: '5/01876',
      left: 0.7945026178010471,
      right: 0.8419502617801047,
      top: 0.14037927844588344,
      bottom: 0.14893617021276595
    )

    create(
      :word,
      text: 'Inhaber:',
      left: 0.007526178010471204,
      right: 0.07787958115183247,
      top: 0.14870490286771507,
      bottom: 0.158418131359852
    )

    create(
      :word,

      text: 'Nina',
      left: 0.08769633507853403,
      right: 0.12303664921465969,
      top: 0.14893617021276595,
      bottom: 0.15818686401480112
    )

    create(
      :word,
      text: 'Trefner',
      left: 0.12958115183246074,
      right: 0.18848167539267016,
      top: 0.14801110083256244,
      bottom: 0.15795559666975023
    )

    create(
      :word,

      text: 'Usrlpg',
      left: 0.7143324607329843,
      right: 0.7526178010471204,
      top: 0.15148011100832562,
      bottom: 0.16443108233117484
    )

    create(
      :word,

      text: '05227921502',
      left: 0.7578534031413613,
      right: 0.8419502617801047,
      top: 0.15148011100832562,
      bottom: 0.16026827012025902
    )

    create(
      :word,
      text: 'UST-ID:',
      left: 0.007853403141361256,
      right: 0.07362565445026178,
      top: 0.16350601295097134,
      bottom: 0.17345050878815912
    )

    create(
      :word,
      text: 'ATU65315367',
      left: 0.0824607329842932,
      right: 0.20026178010471204,
      top: 0.16281221091581868,
      bottom: 0.17321924144310824
    )

    create(
      :word,
      text: 'können',
      left: 0.49705497382198954,
      right: 0.5291230366492147,
      top: 0.8529139685476411,
      bottom: 0.8586956521739131
    )

    create(
      :word,
      text: 'sich',
      left: 0.5330497382198953,
      right: 0.550065445026178,
      top: 0.8529139685476411,
      bottom: 0.8586956521739131
    )

    create(
      :word,
      text: 'geringe',
      left: 0.5536649214659686,
      right: 0.5863874345549738,
      top: 0.853145235892692,
      bottom: 0.8600832562442183
    )

    create(
      :word,
      text: 'Wasser,',
      left: 0.5893324607329843,
      right: 0.6256544502617801,
      top: 0.8529139685476411,
      bottom: 0.8596207215541165
    )

    create(
      :word,
      text: 'bzw.',
      left: 0.6295811518324608,
      right: 0.6492146596858639,
      top: 0.8529139685476411,
      bottom: 0.8586956521739131
    )

    create(
      :word,
      text: 'Kaffeereste',
      left: 0.6534685863874345,
      right: 0.7041884816753927,
      top: 0.8529139685476411,
      bottom: 0.8589269195189639
    )

    create(
      :word,
      text: 'im',
      left: 0.7074607329842932,
      right: 0.7169502617801047,
      top: 0.853145235892692,
      bottom: 0.8586956521739131
    )

    create(
      :word,
      text: 'rät',
      left: 0.7342931937172775,
      right: 0.7454188481675392,
      top: 0.8533765032377428,
      bottom: 0.8589269195189639
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU65315367']
  end
end
