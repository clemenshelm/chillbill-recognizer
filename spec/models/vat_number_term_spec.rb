# frozen_string_literal: true
require_relative '../../lib/boot'

describe VatNumberTerm do
  it 'recognizes German VAT number correctly' do
    # From bill mqJFF5BbAgGSr4pqX
    term = VatNumberTerm.new(text: 'DE147645058')
    expect(term.to_s).to eq 'DE147645058'
  end

  it 'recognizes Austrian VAT number in lower case correctly' do
    # From bill PkAZBBAXapKyNNuqt.pdf
    term = VatNumberTerm.new(text: 'atu67318155')
    expect(term.to_s).to eq 'ATU67318155'
  end
end
