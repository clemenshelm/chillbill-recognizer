require_relative '../../lib/calculations/currency_calculation'

describe CurrencyCalculation do
  it 'uses the first currency' do
    words = %w(EUR USD CHF)
      .map { |code| double(to_iso: code) }

    currency = CurrencyCalculation.new(words)
    expect(currency.iso).to eq "EUR"
  end

  it 'returns nil if there is no currency code' do
    currency = CurrencyCalculation.new([])
    expect(currency.iso).to be_nil
  end
end
