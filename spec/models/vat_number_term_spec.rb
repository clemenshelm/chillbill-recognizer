require_relative '../../lib/boot'
require_relative '../../lib/models/vat_number_term'

describe VatNumberTerm do
  it 'recognizes Austrian VAT number correctly' do
    term = VatNumberTerm.new(text: 'ATU37893801')
    expect(term.to_s).to eq "ATU37893801"
  end

  it 'recognizes German VAT number correctly' do
    term = VatNumberTerm.new(text: 'DE57399425')
    expect(term.to_s).to eq "DE57399425"
  end

  it 'recognizes EU VAT number correctly' do
    term = VatNumberTerm.new(text: 'EU372001951')
    expect(term.to_s).to eq "EU372001951"
  end

  it 'recognizes Luxemburg VAT number correctly' do
    term = VatNumberTerm.new(text: 'LU20260743')
    expect(term.to_s).to eq "LU20260743"
  end

  it 'recognizes Irish VAT number correctly' do
    term = VatNumberTerm.new(text: 'IE6388047V')
    expect(term.to_s).to eq "IE6388047V"
  end
end
