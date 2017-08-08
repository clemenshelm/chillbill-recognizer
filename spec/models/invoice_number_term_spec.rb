# frozen_string_literal: true
require_relative '../../lib/boot'

describe InvoiceNumberTerm do
  it 'recognizes an invoice number correctly' do
    term = InvoiceNumberTerm.new(text: '0547-20151202-02-5059')
    expect(term.to_s).to eq '0547-20151202-02-5059'
  end

  it 'handles unlabeled invoice number' do
    # From 6bWSXJ7fdLRbtbzaE.pdf
    term = InvoiceNumberTerm.new(
      text: '3521 634/092/001/20',
      left: 0.6233638743455497,
      right: 0.7693062827225131,
      top: 0.32993748552905766,
      bottom: 0.3380412132438064,
      needs_label: true
    )

    expect(term.to_s).to eq '3521 634/092/001/20'
    expect(term.needs_label).to eq true
  end
end
