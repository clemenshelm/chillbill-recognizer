require_relative '../../lib/boot'
require_relative '../../lib/models/currency_term'

describe CurrencyTerm do
  it 'recognizes euro symbols correctly' do
    pending('does not detect euro')
    term = CurrencyTerm.new(text: '€')
    expect(term.to_iso).to eq 'EUR'
  end

  it 'recognizes dollar symbols correctly' do
    pending('does not detect dollar')
    term = CurrencyTerm.new(text: '$')
    expect(term.to_iso).to eq 'USD'
  end

  it 'recognizes EUR correctly' do
    pending('does not detect EUR')
    term = CurrencyTerm.new(text: 'EUR')
    expect(term.to_iso).to eq 'EUR'
  end

  it 'recognizes USD correctly' do
    pending('does not detect USD')
    term = CurrencyTerm.new(text: 'USD')
    expect(term.to_iso).to eq 'USD'
  end

  it 'recognizes HKD correctly' do
    pending('does not detect HKD')
    term = CurrencyTerm.new(text: 'HKD')
    expect(term.to_iso).to eq 'HKD'
  end

  it 'recognizes CHF correctly' do
    pending('does not detect CHF')
    term = CurrencyTerm.new(text: 'CHF')
    expect(term.to_iso).to eq 'CHF'
  end

  it 'recognizes SEK correctly' do
    pending('does not detect HRK')
    term = CurrencyTerm.new(text: 'SEK')
    expect(term.to_iso).to eq 'SEK'
  end

  it 'recognizes GBP correctly' do
    pending('does not detect GBP')
    term = CurrencyTerm.new(text: 'GBP')
    expect(term.to_iso).to eq 'GBP'
  end

  it 'recognizes HUF correctly' do
    pending('does not detect HUF')
    term = CurrencyTerm.new(text: 'HUF')
    expect(term.to_iso).to eq 'HUF'
  end

  it 'recognizes HRK correctly' do
    pending('does not detect HRK')
    term = CurrencyTerm.new(text: 'HRK')
    expect(term.to_iso).to eq 'HRK'
  end
end
