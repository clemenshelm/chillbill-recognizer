require_relative '../../lib/boot'
require_relative '../../lib/models/price_term'

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

  it 'recognizes a price with a dash as decimal places and leading euro symbol' do
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
end
