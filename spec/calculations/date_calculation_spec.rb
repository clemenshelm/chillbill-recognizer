require_relative '../../lib/calculations/date_calculation'

describe DateCalculation do
  before(:each) do
    DateTerm.dataset.delete
  end

  it 'uses the first date as invoice date' do
    words = %w(2015-04-01 2015-02-28)
      .map { |date_string| DateTime.iso8601(date_string) }
      .map { |datetime| double(to_datetime: datetime)  }

    dates = DateCalculation.new(words)
    expect(dates.invoice_date).to eq DateTime.iso8601('2015-04-01')
  end

  it 'returns nil if there is no invoice date candidate' do
    dates = DateCalculation.new([])
    expect(dates.invoice_date).to be_nil
  end

  it 'ignores dates from a billing period', :focus do
    DateTerm.create(
      text: "01.03.2015",
      left: 591,
      right: 798,
      top: 773,
      bottom: 809,
      first_word_id: 19
    )

    DateTerm.create(
      text: "31.03.2015",
      left: 832,
      right: 1038,
      top: 773,
      bottom: 809,
      first_word_id: 26
      )

    DateTerm.create(
      text: "10.04.2015",
      left: 2194,
      right: 2397,
      top: 213,
      bottom: 248,
      first_word_id: 40
      )

    BillingPeriodTerm.create(
      text: "01.03.2015 - 31.03.2015",
      from_id: 1,
      to_id: 2
      )

      date_calculation = DateCalculation.new(
        DateTerm.dataset
      )
    expect(date_calculation.invoice_date).to eq DateTime.iso8601('2015-04-10')
  end
end
