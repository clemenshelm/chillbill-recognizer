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

  it 'detects the billing period using billing period labels' do
    # From m4F2bLmpKn7wPqM7q.pdf
    BillingStartLabelTerm.create(
      text: 'Billing Start:',
      left: 0.4525523560209424,
      right: 0.4849476439790576,
      top: 0.1593432007400555,
      bottom: 0.16651248843663274
    )

    DateTerm.create(
      text: '22 October 2016',
      left: 0.5788612565445026,
      right: 0.6070026178010471,
      top: 0.1593432007400555,
      bottom: 0.16628122109158186
    )

    BillingEndLabelTerm.create(
      text: 'Billing End:',
      left: 0.45287958115183247,
      right: 0.4800392670157068,
      top: 0.17437557816836263,
      bottom: 0.18131359851988899
    )

    DateTerm.create(
      text: '27 October 2016',
      left: 0.5788612565445026,
      right: 0.6070026178010471,
      top: 0.17414431082331175,
      bottom: 0.1810823311748381
    )

    calculated_billing_period = BillingPeriodCalculation.new(
      DateTerm.dataset
    ).billing_period

    expect(calculated_billing_period[:from]).to eq DateTime.iso8601(
      '2016-10-22'
    )
    expect(calculated_billing_period[:to]).to eq DateTime.iso8601(
      '2016-10-27'
    )
  end
end
