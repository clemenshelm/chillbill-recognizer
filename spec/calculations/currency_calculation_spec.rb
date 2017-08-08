# frozen_string_literal: true
require_relative '../../lib/calculations/currency_calculation'

describe CurrencyCalculation do
  it 'detects currency code which appear most often in bill' do
    # Missing label - needs Ft.

    PriceTerm.create(
      text: '9900',
      left: 0.6596858638743456,
      right: 0.6848821989528796,
      top: 0.6588806660499538,
      bottom: 0.6648936170212766
    )
    CurrencyTerm.create(
      text: 'EUR',
      left: 0.5556666666666666,
      right: 0.58,
      top: 0.10742049469964664,
      bottom: 0.11401648998822143
    )

    CurrencyTerm.create(
      text: '(HUF)',
      left: 0.48833333333333334,
      right: 0.528,
      top: 0.31142520612485275,
      bottom: 0.3215547703180212
    )

    CurrencyTerm.create(
      text: 'Ft.',
      left: 0.961,
      right: 0.9743333333333334,
      top: 0.37385159010600705,
      bottom: 0.38021201413427563
    )

    CurrencyTerm.create(
      text: 'Ft.',
      left: 0.8656666666666667,
      right: 0.8786666666666667,
      top: 0.3992932862190813,
      bottom: 0.4056537102473498
    )

    currency = CurrencyCalculation.new.iso
    expect(currency).to eq 'HUF'
  end

  it 'detects correct currency after first price' do
    # From 6rYBRincCdkNbCeRB.pdf

    PriceTerm.create(
      text: '20,54',
      left: 0.39659685863874344,
      right: 0.44273560209424084,
      top: 0.6228029602220166,
      bottom: 0.6339037927844589
    )

    CurrencyTerm.create(
      text: '€',
      left: 0.4489528795811518,
      right: 0.4587696335078534,
      top: 0.6228029602220166,
      bottom: 0.6322849213691026
    )

    CurrencyTerm.create(
      text: '£0.00',
      left: 0.5569371727748691,
      right: 0.5916230366492147,
      top: 0.6228029602220166,
      bottom: 0.6339037927844589
    )

    currency = CurrencyCalculation.new.iso
    expect(currency).to eq 'EUR'
  end

  it 'returns nil if there is no currency code' do
    currency = CurrencyCalculation.new
    expect(currency.iso).to be_nil
  end

  it 'returns the most accurate currency term without a price present' do
    # From 3NcAALw3DfrfuLRJ4.png
    CurrencyTerm.create(
      text: 'EUR',
      left: 0.9229607250755287,
      right: 0.9561933534743202,
      top: 0.77196261682243,
      bottom: 0.7869158878504673
    )

    CurrencyTerm.create(
      text: 'EUR',
      left: 0.9229607250755287,
      right: 0.9561933534743202,
      top: 0.8542056074766355,
      bottom: 0.8691588785046729
    )

    currency = CurrencyCalculation.new.iso
    expect(currency).to eq 'EUR'
  end
end
