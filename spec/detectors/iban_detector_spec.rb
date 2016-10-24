# frozen_string_literal: true
require_relative '../../lib/boot'
require_relative '../../lib/detectors/iban_detector'
require_relative '../../lib/models/word'
require_relative '../support/factory_girl'
require_relative '../factories'

describe IbanDetector do
  before(:each) do
    Word.dataset.delete
    IbanTerm.dataset.delete
  end

  it 'recognizes IBAN seperated by a space' do
    create(
      :word,
      text: 'IBAN:',
      left: 1230,
      right: 1348,
      top: 3025,
      bottom: 3060
    )

    create(
      :word,
      text: 'AT28',
      left: 1365,
      right: 1477,
      top: 3025,
      bottom: 3061
    )

    create(
      :word,
      text: '12000',
      left: 1497,
      right: 1631,
      top: 3025,
      bottom: 3061
    )

    create(
      :word,
      text: '10011287801',
      left: 1650,
      right: 1952,
      top: 3025,
      bottom: 3061
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT281200010011287801']
  end

  it 'recognizes separated IBAN' do
    create(
      :word,
      text: 'ibon',
      left: 838,
      right: 984,
      top: 2550,
      bottom: 2606
    )

    create(
      :word,
      text: 'AT85',
      left: 1029,
      right: 1217,
      top: 2537,
      bottom: 2605
    )

    create(
      :word,
      text: '11000',
      left: 1258,
      right: 1484,
      top: 2537,
      bottom: 2605
    )

    create(
      :word,
      text: '10687568500',
      left: 1523,
      right: 2036,
      top: 2537,
      bottom: 2605
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT851100010687568500']
  end

  it 'recognizes Austrian IBAN number without space' do
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
      text: 'AT851100010687868500',
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

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT851100010687868500']
  end

  it 'recognizes separated iban with four digits' do
    create(
      :word,
      text: 'AT10',
      left: 1487,
      right: 2118,
      top: 3849,
      bottom: 3882
    )

    create(
      :word,
      text: '3225',
      left: 2130,
      right: 2386,
      top: 3850,
      bottom: 3882
    )

    create(
      :word,
      text: '0000',
      left: 2416,
      right: 2492,
      top: 3850,
      bottom: 3881
    )

    create(
      :word,
      text: '0001',
      left: 2503,
      right: 2615,
      top: 3850,
      bottom: 3882
    )

    create(
      :word,
      text: '3300',
      left: 2503,
      right: 2615,
      top: 3850,
      bottom: 3882
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT103225000000013300']
  end
end
