require_relative '../../lib/boot'
require_relative '../../lib/models/vat_number_term'

describe VatNumberTerm do
  it 'recognizes Austrian VAT number correctly' do
    term = VatNumberTerm.new(text: 'ATU37893801')
    expect(term.to_s).to eq "ATU37893801"
  end
end
