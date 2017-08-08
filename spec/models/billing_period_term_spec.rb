# frozen_string_literal: true
require_relative '../support/factory_girl'
require_relative '../factories'

describe BillingPeriodTerm do
  # From 28YRpHtS7R3qwEfMR.pdf
  it 'sets the correct values for a billing period' do
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

    billing_period = BillingPeriodTerm.create(
      from: start_of_period,
      to: end_of_period
    )

    expect(billing_period.from).to eq start_of_period
    expect(billing_period.to).to eq end_of_period
  end
end
