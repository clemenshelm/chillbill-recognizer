# frozen_string_literal: true
require_relative '../../lib/boot'

describe PriceTerm do
  it 'recognizes price with comma separator and euro sign behind' do
    term = PriceTerm.new(text: '15,90€')
    expect(term.to_d).to eq 15.90
  end

  it 'recognizes price with point separator' do
    term = PriceTerm.new(text: '15.90')
    expect(term.to_d).to eq 15.90
  end

  it 'recognizes a price with a dash as decimal places' do
    term = PriceTerm.new(text: '1000,-')
    expect(term.to_d).to eq 1000.00
  end

  it 'recognizes a price with a - as decimal places & leading euro symbol' do
    term = PriceTerm.new(text: '€1000,-')
    expect(term.to_d).to eq 1000.00
  end

  it 'finds a price without decimal places with the currency symbol behind' do
    term = PriceTerm.new(text: '1500€')
    expect(term.to_d).to eq 1500.00
  end

  it 'finds a price with decimal places with leading currency symbol' do
    term = PriceTerm.new(text: '€1480.50')
    expect(term.to_d).to eq 1480.50
  end

  it 'finds a price with decimal places(comma) with leading currency symbol' do
    term = PriceTerm.new(text: '€1480,50')
    expect(term.to_d).to eq 1480.50
  end

  it 'finds a price with decimal places(comma) with leading currency symbol' do
    term = PriceTerm.new(text: '€1480,50')
    expect(term.to_d).to eq 1480.50
  end

  it 'finds a price with comma, period and a leading currency symbol' do
    term = PriceTerm.new(text: '€1,202.16')
    expect(term.to_d).to eq 1202.16
  end

  it 'expext price to have space in betweeen' do
    term = PriceTerm.new(text: '11 038 ')
    expect(term.to_d).to eq 11_038
  end

  it 'expect price to be negative' do
    term = PriceTerm.new(text: '-12,00')
    expect(term.to_d).to == -12.00
  end

  describe 'to_h' do
    it 'creates a hash representing the price term' do
      term = PriceTerm.new(
        text: '1234,56', top: 1, bottom: 2, left: 3, right: 4
      )
      expect(term.to_h).to eq(
        'text' => '1234,56',
        'price' => 123_456,
        'top' => 1,
        'bottom' => 2,
        'left' => 3,
        'right' => 4
      )
    end
  end
end
