# frozen_string_literal: true
require_relative '../../lib/boot'

describe BillingEndLabelTerm do
  it 'detects a billing end label correctly' do
    # From m4F2bLmpKn7wPqM7q.pdf
    term = BillingEndLabelTerm.new(
      text: 'Billing End:',
      left: 0.450261780104712,
      right: 0.5209424083769634,
      top: 0.26595744680851063,
      bottom: 0.27451433857539315
    )

    expect(term.to_s).to eq 'Billing End:'
  end
end
