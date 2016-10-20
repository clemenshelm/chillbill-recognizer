# frozen_string_literal: true
require_relative '../../lib/calculations/billing_period_calculation'

describe BillingPeriodCalculation do
  it 'returns the billing period attributes in the correct format' do
    start_of_period = DateTerm.create(
      text: '01.03.2015',
      left: 591,
      right: 798,
      top: 773,
      bottom: 809,
      first_word_id: 19
    )

    end_of_period = DateTerm.create(
      text: '31.03.2015',
      left: 832,
      right: 1038,
      top: 773,
      bottom: 809,
      first_word_id: 26
    )

    billing_period_terms = [BillingPeriodTerm.create(
      from: start_of_period,
      to: end_of_period
    )]

    calculated_billing_period = BillingPeriodCalculation.new(
      billing_period_terms
    ).billing_period
    expect(calculated_billing_period[:from]).to eq DateTime.iso8601(
      '2015-03-01'
    )
    expect(calculated_billing_period[:to]).to eq DateTime.iso8601(
      '2015-03-31'
    )
  end

  it 'returns nil if there is no billing period' do
    billing_period = BillingPeriodCalculation.new([])
    expect(billing_period.billing_period).to be_nil
  end
end
