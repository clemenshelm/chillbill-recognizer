require_relative '../../lib/calculations/date_calculation'

describe DateCalculation do
  it 'uses the first date as invoice date' do
    words = %w(2015-04-01 2015-02-28)
            .map { |date_string| DateTime.iso8601(date_string) }
            .map { |datetime| double(to_datetime: datetime) }

    dates = DateCalculation.new(words)
    expect(dates.invoice_date).to eq DateTime.iso8601('2015-04-01')
  end

  it 'returns nil if there is no invoice date candidate' do
    dates = DateCalculation.new([])
    expect(dates.invoice_date).to be_nil
  end
end
