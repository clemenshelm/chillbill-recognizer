# frozen_string_literal: true
require_relative '../../lib/boot'

describe InvoiceNumberTerm do
  it 'recognizes an invoice number correctly' do
    term = InvoiceNumberTerm.new(text: '0547-20151202-02-5059')
    expect(term.to_s).to eq '0547-20151202-02-5059'
  end
end
