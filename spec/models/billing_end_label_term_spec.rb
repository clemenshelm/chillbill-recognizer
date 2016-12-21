# frozen_string_literal: true
require_relative '../../lib/boot'

describe BillingEndLabelTerm do
  it 'detects a billing end label correctly' do
    # From m4F2bLmpKn7wPqM7q.pdf
    term = BillingEndLabelTerm.new(
      text: "Billing End:",
      left: 0.45287958115183247,
      right: 0.4800392670157068,
      top: 0.17437557816836263,
      bottom: 0.18131359851988899
    )

    expect(term.to_s).to eq 'Billing End:'
  end
end
