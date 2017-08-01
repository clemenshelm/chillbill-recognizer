# frozen_string_literal: true
require_relative '../../lib/boot'

describe BillingStartLabelTerm do
  it 'detects a billing start label correctly' do
    # From m4F2bLmpKn7wPqM7q.pdf
    term = BillingStartLabelTerm.new(
      text: 'Billing Start:',
      left: 0.450261780104712,
      right: 0.5258507853403142,
      top: 0.2511563367252544,
      bottom: 0.259713228492136
    )

    expect(term.to_s).to eq 'Billing Start:'
  end
end
