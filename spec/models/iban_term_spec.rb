# frozen_string_literal: true
require_relative '../../lib/models/iban_term'

describe IbanTerm do
  it 'recognizes Austrian IBAN correctly' do
    term = IbanTerm.new(text: 'AT185600020141333306')
    expect(term.to_s).to eq 'AT185600020141333306'
  end

  it 'recognizes German IBAN correctly' do
    term = IbanTerm.new(text: 'DE86 51230800 6530481295')
    expect(term.to_s).to eq 'DE86512308006530481295'
  end

  it 'recognizes Croatian IBAN correctly' do
    term = IbanTerm.new(text: 'HR0923 60000 110167 5865')
    expect(term.to_s).to eq 'HR0923600001101675865'
  end
end
