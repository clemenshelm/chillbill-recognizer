require_relative '../../lib/boot'
require_relative '../../lib/models/date_term'

describe DateTerm do
  it 'recognizes dates with a two-digit year correctly' do
    term = DateTerm.new(text: '13.04.15')
    expect(term.to_datetime).to eq DateTime.iso8601('2015-04-13')
  end

  it 'recognizes dates in full german format' do
    term = DateTerm.new(text: '23. April 2015')
    expect(term.to_datetime).to eq DateTime.iso8601('2015-04-23')
  end

  it 'recognizes dates in full german format' do
    term = DateTerm.new(text: '23. April 2015')
    expect(term.to_datetime).to eq DateTime.iso8601('2015-04-23')
  end
end
