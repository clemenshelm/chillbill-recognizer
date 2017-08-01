# frozen_string_literal: true
require_relative '../../lib/calculations/billing_period_calculation'

describe BillingPeriodCalculation do
  it 'returns the billing period attributes in the correct format' do
    # From 28YRpHtS7R3qwEfMR.pdf
    start_of_period = DateTerm.create(
      text: '01.03.2016',
      left: 0.27347072293097807,
      right: 0.34249263984298334,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625,
      first_word_id: 22
    )

    end_of_period = DateTerm.create(
      text: '31.03.2016',
      left: 0.35361465489041544,
      right: 0.42263657180242065,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625,
      first_word_id: 24
    )

    BillingPeriodTerm.create(
      from: start_of_period,
      to: end_of_period
    )

    calculated_billing_period = BillingPeriodCalculation.new.billing_period
    expect(calculated_billing_period[:from]).to eq DateTime.iso8601(
      '2016-03-01'
    )
    expect(calculated_billing_period[:to]).to eq DateTime.iso8601(
      '2016-03-31'
    )
  end

  it 'returns nil if there is no billing period' do
    billing_period = BillingPeriodCalculation.new
    expect(billing_period.billing_period).to be_nil
  end
end
