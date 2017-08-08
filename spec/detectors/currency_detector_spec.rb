# frozen_string_literal: true
require_relative '../../lib/detectors/currency_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe CurrencyDetector do
  it 'recognizes EUR currency on a bill' do
    # From 3NcAALw3DfrfuLRJ4.png
    create(
      :word,
      text: 'EUR',
      left: 0.9229607250755287,
      right: 0.9561933534743202,
      top: 0.77196261682243,
      bottom: 0.7869158878504673
    )

    create(
      :word,
      text: 'sum.,',
      left: 0.716012084592145,
      right: 0.7749244712990937,
      top: 0.794392523364486,
      bottom: 0.8093457943925234
    )

    create(
      :word,
      text: 'saaaszurz',
      left: 0.8670694864048338,
      right: 0.9561933534743202,
      top: 0.794392523364486,
      bottom: 0.8093457943925234
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(EUR)
  end

  it 'recognizes € currency on a bill' do
    # From 6rYBRincCdkNbCeRB.pdf
    create(
      :word,
      text: '20,54',
      left: 0.8406413612565445,
      right: 0.8864528795811518,
      top: 0.5413968547641073,
      bottom: 0.5531914893617021
    )

    create(
      :word,
      text: '€',
      left: 0.8923429319371727,
      right: 0.9024869109947644,
      top: 0.5413968547641073,
      bottom: 0.5511100832562442
    )

    create(
      :word,
      text: 'Menge',
      left: 0.07591623036649214,
      right: 0.13383507853403143,
      top: 0.4794172062904718,
      bottom: 0.4921369102682701
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(EUR)
  end

  it 'recognizes USD and $ currency on a bill' do
    # Missing label - needs USD and $
    create(
      :word,
      text: 'USD',
      left: 656,
      right: 797,
      top: 1190,
      bottom: 1244
    )

    create(
      :word,
      text: '$140.00',
      left: 822,
      right: 1071,
      top: 1187,
      bottom: 1250
    )

    create(
      :word,
      text: 'Date',
      left: 1787,
      right: 1932,
      top: 1191,
      bottom: 1244
    )

    create(
      :word,
      text: 'Paid:',
      left: 1958,
      right: 2120,
      top: 1191,
      bottom: 1244
    )

    create(
      :word,
      text: '11',
      left: 2152,
      right: 2213,
      top: 1191,
      bottom: 1242
    )

    create(
      :word,
      text: 'Jun',
      left: 2245,
      right: 2364,
      top: 1191,
      bottom: 1244
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(USD USD)
  end

  it 'recognizes CHF currency on a bill' do
    # Missing label - needs CHF
    create(
      :word,
      text: 'CHF',
      left: 708,
      right: 1147,
      top: 537,
      bottom: 689
    )

    create(
      :word,
      text: '16.00',
      left: 2253,
      right: 2718,
      top: 526,
      bottom: 684
    )

    create(
      :word,
      text: 'Total',
      left: 162,
      right: 467,
      top: 749,
      bottom: 859
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(CHF)
  end

  it 'regcognizes CNY currency on the bill' do
    # From 4KGwfH74J25TQgMGX.pdf
    create(
      :word,
      text: 'CNY',
      left: 0.7833769633507853,
      right: 0.8160994764397905,
      top: 0.697383653623524,
      bottom: 0.7059504514934013
    )

    create(
      :word,
      text: '3,685',
      left: 0.8213350785340314,
      right: 0.8602748691099477,
      top: 0.697383653623524,
      bottom: 0.7078027321139153
    )

    create(
      :word,
      text: 'CNY',
      left: 0.756871727748691,
      right: 0.8017015706806283,
      top: 0.725167862931234,
      bottom: 0.7362815466543181
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(CNY CNY)
  end

  it 'regcognizes SEK currency on the bill' do
    # Missing label - needs SEK
    create(
      :word,
      text: 'SEK',
      left: 842,
      right: 919,
      top: 2084,
      bottom: 2124
    )

    create(
      :word,
      text: 'Moms',
      left: 28,
      right: 156,
      top: 2175,
      bottom: 2216
    )

    create(
      :word,
      text: '12%',
      left: 174,
      right: 261,
      top: 2175,
      bottom: 2216
    )

    create(
      :word,
      text: '590.36',
      left: 675,
      right: 817,
      top: 2176,
      bottom: 2216
    )

    create(
      :word,
      text: 'SEK',
      left: 842,
      right: 918,
      top: 2176,
      bottom: 2217
    )

    create(
      :word,
      text: 'l',
      left: 1067,
      right: 1080,
      top: 2173,
      bottom: 2225
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(SEK SEK)
  end

  it 'regcognizes GBP currency on the bill' do
    # Missing label - needs GBP
    create(
      :word,
      text: '£45.00',
      left: 2056,
      right: 2393,
      top: 4038,
      bottom: 4160
    )

    create(
      :word,
      text: '4',
      left: 115,
      right: 162,
      top: 4207,
      bottom: 4323
    )

    create(
      :word,
      text: 'Mineral',
      left: 226,
      right: 611,
      top: 4201,
      bottom: 4323
    )

    create(
      :word,
      text: 'Water',
      left: 685,
      right: 966,
      top: 4204,
      bottom: 4323
    )

    create(
      :word,
      text: 'Bettie',
      left: 1024,
      right: 1364,
      top: 4197,
      bottom: 4319
    )

    create(
      :word,
      text: '£22.00',
      left: 2056,
      right: 2393,
      top: 4201,
      bottom: 4319
    )

    create(
      :word,
      text: 'w',
      left: 1,
      right: 2401,
      top: 4422,
      bottom: 4495
    )

    create(
      :word,
      text: 'Amt.Due',
      left: 685,
      right: 1080,
      top: 4526,
      bottom: 4642
    )

    create(
      :word,
      text: '£564',
      left: 1545,
      right: 1983,
      top: 4523,
      bottom: 4642
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(GBP GBP GBP)
  end

  it 'regcognizes £ currency on the bill' do
    # Missing label - needs £
    create(
      :word,
      text: '£45.00',
      left: 2056,
      right: 2393,
      top: 4038,
      bottom: 4160
    )

    create(
      :word,
      text: '4',
      left: 115,
      right: 162,
      top: 4207,
      bottom: 4323
    )

    create(
      :word,
      text: 'Mineral',
      left: 226,
      right: 611,
      top: 4201,
      bottom: 4323
    )

    create(
      :word,
      text: 'Water',
      left: 685,
      right: 966,
      top: 4204,
      bottom: 4323
    )

    create(
      :word,
      text: 'Bettie',
      left: 1024,
      right: 1364,
      top: 4197,
      bottom: 4319
    )

    create(
      :word,
      text: '£22.00',
      left: 2056,
      right: 2393,
      top: 4201,
      bottom: 4319
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq %w(GBP GBP)
  end

  it 'detects HUF as Ft. on a bill' do
    # Missing label - needs Ft.
    create(
      :word,
      text: 'Ft.',
      left: 0.8656666666666667,
      right: 0.8786666666666667,
      top: 0.3992932862190813,
      bottom: 0.4056537102473498
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq ['HUF']
  end

  it 'detects EUR as Euro on a bill' do
    # From mMHiT2b3C5fgYqBzY.pdf
    create(
      :word,
      text: 'Summe',
      left: 0.5991492146596858,
      right: 0.6564136125654451,
      top: 0.9298123697011814,
      bottom: 0.938846421125781
    )

    create(
      :word,
      text: 'Euro',
      left: 0.6632853403141361,
      right: 0.6966623036649214,
      top: 0.9300440120454019,
      bottom: 0.9388464211257818
    )

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:to_iso)).to eq ['EUR']
  end
end
