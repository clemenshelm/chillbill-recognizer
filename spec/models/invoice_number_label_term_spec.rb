# frozen_string_literal: true
require_relative '../../lib/boot'
require_relative '../../lib/models/invoice_number_label_term'

describe InvoiceNumberLabelTerm do
  it 'returns invoice number label correctly' do
    term = InvoiceNumberLabelTerm.new(text: 'Re-Nr:')
    expect(term.to_s).to eq 'Re-Nr:'
  end
end
