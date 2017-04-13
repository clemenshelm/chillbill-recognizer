# frozen_string_literal: true
require_relative '../../lib/boot'
require_relative '../../lib/models/vat_number_term'

describe VatNumberTerm do
  it 'recognizes Austrian VAT number correctly' do
    term = VatNumberTerm.new(text: 'ATU37893801')
    expect(term.to_s).to eq 'ATU37893801'
  end

  it 'recognizes Austrian VAT number in lower case correctly' do
    term = VatNumberTerm.new(text: 'atu67318155')
    expect(term.to_s).to eq 'ATU67318155'
  end
end
