# frozen_string_literal: true
require_relative '../../lib/detectors/iban_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe IbanDetector do
  it 'recognizes IBAN seperated by a space' do
    # From 7FDFZnmZmfMyxWZtG.pdf
    create(
      :word,
      text: 'IBAN:',
      left: 0.5317408376963351,
      right: 0.5713350785340314,
      top: 0.8061979648473635,
      bottom: 0.8142923219241444
    )

    create(
      :word,
      text: 'AT28',
      left: 0.5768979057591623,
      right: 0.6138743455497382,
      top: 0.8061979648473635,
      bottom: 0.8142923219241444
    )

    create(
      :word,
      text: '12000',
      left: 0.6210732984293194,
      right: 0.6652486910994765,
      top: 0.8061979648473635,
      bottom: 0.8142923219241444
    )

    create(
      :word,
      text: '10011287801',
      left: 0.6721204188481675,
      right: 0.7722513089005235,
      top: 0.8061979648473635,
      bottom: 0.8142923219241444
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT281200010011287801']
  end

  it 'recognizes separated IBAN' do
    # From 4WaHezqC7H7HgDzcy.pdf
    create(
      :word,
      text: 'ibom',
      left: 0.33496892378148513,
      right: 0.3837095191364082,
      top: 0.6888734674994217,
      bottom: 0.7013647929678464
    )

    create(
      :word,
      text: 'AT85',
      left: 0.39842983316977426,
      right: 0.460582270199542,
      top: 0.6856349757113116,
      bottom: 0.7013647929678464
    )

    create(
      :word,
      text: '11000',
      left: 0.47497546614327774,
      right: 0.5498855086686294,
      top: 0.6856349757113116,
      bottom: 0.7013647929678464
    )

    create(
      :word,
      text: '10687568500',
      left: 0.563297350343474,
      right: 0.7333987569512594,
      top: 0.6856349757113116,
      bottom: 0.7013647929678464
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT851100010687568500']
  end

  it 'recognizes Austrian IBAN number without space' do
    # From 9NwagojCEgB3Ex92B.pdf
    create(
      :word,
      text: 'UID',
      left: 0.6404972194962382,
      right: 0.6578344782466471,
      top: 0.9218135554013417,
      bottom: 0.9275965764515383
    )

    create(
      :word,
      text: 'AT103225000000013300',
      left: 0.4370297677461564,
      right: 0.5763820739286882,
      top: 0.9324543141337035,
      bottom: 0.9382373351839001
    )

    create(
      :word,
      text: '+43',
      left: 0.12921164540399083,
      right: 0.14753025842329082,
      top: 0.9324543141337035,
      bottom: 0.9382373351839001
    )

    create(
      :word,
      text: '2236',
      left: 0.15145567549885508,
      right: 0.17598953222113184,
      top: 0.9324543141337035,
      bottom: 0.9382373351839001
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT103225000000013300']
  end

  it 'recognizes separated iban with four digits' do
    # From 2Z5ZYYjfvhvDdhkvw.pdf
    create(
      :word,
      text: 'AT10',
      left: 0.4370297677461564,
      right: 0.46123650637880276,
      top: 0.9326856349757113,
      bottom: 0.9382373351839001
    )

    create(
      :word,
      text: '3225',
      left: 0.46483480536473665,
      right: 0.4893686620870134,
      top: 0.9326856349757113,
      bottom: 0.9384686560259079
    )

    create(
      :word,
      text: '0000',
      left: 0.49329407916257767,
      right: 0.5184821720641152,
      top: 0.9326856349757113,
      bottom: 0.9384686560259079
    )

    create(
      :word,
      text: '0001',
      left: 0.5224075891396794,
      right: 0.5456329735034348,
      top: 0.9326856349757113,
      bottom: 0.9384686560259079
    )

    create(
      :word,
      text: '3300',
      left: 0.5508668629375204,
      right: 0.5763820739286882,
      top: 0.9326856349757113,
      bottom: 0.9384686560259079
    )

    iban = IbanDetector.filter
    expect(iban.map(&:to_s)).to eq ['AT103225000000013300']
  end
end
