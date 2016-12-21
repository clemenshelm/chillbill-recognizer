# frozen_string_literal: true
require_relative '../../lib/boot'

describe BillingStartLabelTerm do
  it 'detects a billing start label correctly' do
    # From m4F2bLmpKn7wPqM7q.pdf
    term = BillingStartLabelTerm.new(
      text: "Billing Start:",
      left: 0.4525523560209424,
      right: 0.4849476439790576,
      top: 0.1593432007400555,
      bottom: 0.16651248843663274
    )

    expect(term.to_s).to eq 'Billing Start:'
  end
end
