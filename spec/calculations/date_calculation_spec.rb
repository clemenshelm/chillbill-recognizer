# frozen_string_literal: true
require_relative '../../lib/calculations/date_calculation'

describe DateCalculation do
  it 'returns nil if there is no invoice date candidate' do
    dates = DateCalculation.new([])
    expect(dates.invoice_date).to be_nil
  end

  it 'ignores dates from a billing period' do
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

    DateTerm.create(
      text: '10.04.2015',
      left: 2194,
      right: 2397,
      top: 213,
      bottom: 248,
      first_word_id: 40
    )

    BillingPeriodTerm.create(
      from: start_of_period,
      to: end_of_period
    )

    date_calculation = DateCalculation.new(
      DateTerm.dataset
    )
    expect(date_calculation.invoice_date).to eq DateTime.iso8601('2015-04-10')
  end

  it 'recognizes the first date as the invoice date' do
    DateTerm.create(
      text: '16.03.2016',
      left: 1819,
      right: 2026,
      top: 498,
      bottom: 529
    )

    DateTerm.create(
      text: '21.03.2016',
      left: 1816,
      right: 2026,
      top: 586,
      bottom: 618
    )

    date_calculation = DateCalculation.new(
      DateTerm.dataset
    )
    expect(date_calculation.invoice_date).to eq DateTime.iso8601('2016-03-16')
  end

  it 'recognizes first date as a long slash date regex' do
    DateTerm.create(
      text: '13/08/2016',
      left: 1819,
      right: 2026,
      top: 498,
      bottom: 529
    )

    DateTerm.create(
      text: '13/08/16',
      left: 1819,
      right: 2026,
      top: 498,
      bottom: 529
    )

    date_calculation = DateCalculation.new(
      DateTerm.dataset
    )
    expect(date_calculation.invoice_date).to eq DateTime.iso8601('2016-08-13')
  end
end
