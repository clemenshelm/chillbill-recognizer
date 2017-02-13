2# frozen_string_literal: true
require_relative '../../lib/calculations/currency_calculation'

describe CurrencyCalculation do
  it 'detects currency code which appear most often in bill' do
    # From bsg8XJqLBJSt2dXeH.pdf

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
      left: 0.7735602094240838,
      right: 0.819371727748691,
      top: 0.4405642923219241,
      bottom: 0.45166512488436633
    )

    CurrencyTerm.create(
      text: '€',
      left: 0.8255890052356021,
      right: 0.8354057591623036,
      top: 0.4405642923219241,
      bottom: 0.45004625346901017
    )

    CurrencyTerm.create(
      text: '£0.00',
      left: 0.5765706806282722,
      right: 0.6220549738219895,
      top: 0.5640610545790934,
      bottom: 0.5740055504162812
    )

    currency = CurrencyCalculation.new.iso
    expect(currency).to eq 'EUR'
  end

  it 'returns nil if there is no currency code' do
    currency = CurrencyCalculation.new
    expect(currency.iso).to be_nil
  end

  it "returns the most accurate currency term without a price present" do
    # From 3NcAALw3DfrfuLRJ4.png
    CurrencyTerm.create(
      text: 'EUR',
      left: 0.37009063444108764,
      right: 0.4123867069486405,
      top: 0.20186915887850468,
      bottom: 0.2205607476635514
    )

    CurrencyTerm.create(
      text: 'EUR',
      left: 0.6132930513595166,
      right: 0.6465256797583081,
      top: 0.6186915887850467,
      bottom: 0.6336448598130842,
    )

    currency = CurrencyCalculation.new.iso
    expect(currency).to eq 'EUR'
  end
end
