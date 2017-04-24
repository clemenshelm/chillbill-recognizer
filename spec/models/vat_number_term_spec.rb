# frozen_string_literal: true
require_relative '../../lib/boot'

describe VatNumberTerm do
  it 'recognizes Austrian VAT number correctly' do
    term = VatNumberTerm.new(text: 'ATU37893801')
    expect(term.to_s).to eq 'ATU37893801'
  end
end
