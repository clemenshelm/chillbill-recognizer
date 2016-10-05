require_relative '../../lib/boot'
require_relative '../../lib/models/billing_period_term'

describe BillingPeriodTerm do
  it "returns the correct values for a billing period" do
    term = BillingPeriodTerm.new(text: '13.04.15')
    expect(term.to_datetime).to eq DateTime.iso8601('2015-04-13')
  end
end
