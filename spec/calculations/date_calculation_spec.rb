require_relative '../../lib/calculations/date_calculation'

describe DateCalculation, :focus do
  it 'uses the first date as invoice date' do
    words = %w(01.04.2015 28.02.15).
      map { |text| double(text: text)  }

    dates = DateCalculation.new(words)
    expect(dates.invoice_date).to eq DateTime.iso8601('2015-04-01')
  end

  it 'recognizes dates with a two-digit year correctly' do
    words = [double(text: '13.04.15')]

    dates = DateCalculation.new(words)
    expect(dates.invoice_date).to eq DateTime.iso8601('2015-04-13')
  end

  it 'returns nil if there is no invoice date candidate' do
    dates = DateCalculation.new([])
    expect(dates.invoice_date).to be_nil
  end

  it 'recognizes dates in full german format' do
    words = [double(text: '23. April 2015')]

    dates = DateCalculation.new(words)
    expect(dates.invoice_date).to eq DateTime.iso8601('2015-04-23')
  end
end
