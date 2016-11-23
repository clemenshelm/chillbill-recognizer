# frozen_string_literal: true
require_relative '../../lib/calculations/currency_calculation'

describe CurrencyCalculation do
  it 'uses the last currency detected' do
    # From bsg8XJqLBJSt2dXeH.pdf
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


    currency = CurrencyCalculation.new(CurrencyTerm.dataset).iso
    expect(currency).to eq 'Ft.'

  end

  it 'returns nil if there is no currency code' do
    currency = CurrencyCalculation.new([])
    expect(currency.iso).to be_nil
  end
end
