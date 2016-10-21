# frozen_string_literal: true
require_relative '../../lib/boot'
require_relative '../../lib/models/currency_term'

describe CurrencyTerm do
  it 'recognizes euro symbols correctly' do
    term = CurrencyTerm.create(text: '€')
    expect(term.to_iso).to eq 'EUR'
  end

  it 'recognizes dollar symbols correctly' do
    term = CurrencyTerm.new(text: '$')
    expect(term.to_iso).to eq 'USD'
  end

  it 'recognizes EUR correctly' do
    term = CurrencyTerm.new(text: 'EUR')
    expect(term.to_iso).to eq 'EUR'
  end

  it 'recognizes USD correctly' do
    term = CurrencyTerm.new(text: 'USD')
    expect(term.to_iso).to eq 'USD'
  end

  it 'recognizes HKD correctly' do
    term = CurrencyTerm.new(text: 'HKD')
    expect(term.to_iso).to eq 'HKD'
  end

  it 'recognizes CHF correctly' do
    term = CurrencyTerm.new(text: 'CHF')
    expect(term.to_iso).to eq 'CHF'
  end

  it 'recognizes SEK correctly' do
    term = CurrencyTerm.new(text: 'SEK')
    expect(term.to_iso).to eq 'SEK'
  end

  it 'recognizes GBP correctly' do
    term = CurrencyTerm.new(text: 'GBP')
    expect(term.to_iso).to eq 'GBP'
  end

  it 'recognizes HUF correctly' do
    term = CurrencyTerm.new(text: 'HUF')
    expect(term.to_iso).to eq 'HUF'
  end

  it 'recognizes HRK correctly' do
    term = CurrencyTerm.new(text: 'HRK')
    expect(term.to_iso).to eq 'HRK'
  end
end
