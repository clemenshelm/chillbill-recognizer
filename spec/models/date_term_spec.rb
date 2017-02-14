# frozen_string_literal: true
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

  it 'recognizes dates in the dd/mm/yy format' do
    term = DateTerm.new(text: '1/03/16')
    expect(term.to_datetime).to eq DateTime.iso8601('2016-03-01')
  end

  it 'recognizes dates in the dd/mm/yyyy format' do
    term = DateTerm.new(text: '12/03/2016')
    expect(term.to_datetime).to eq DateTime.iso8601('2016-03-12')
  end

  it 'recognizes dates in the d. mm yyyy format' do
    term = DateTerm.new(text: '3. Oktober 2016')
    expect(term.to_datetime).to eq DateTime.iso8601('2016-10-03')
  end

  it 'recognizes dates in the short english format' do
    # From 8XJegsB4tn8XRuZpp.pdf
    term = DateTerm.new(text: '03-Oct-2016')
    expect(term.to_datetime).to eq DateTime.iso8601('2016-10-03')
  end

  it 'recognizes dates in format yyyy/mm/dd' do
    # From SaJwGfhgFR6FxCoxe.pdf
    term = DateTerm.new(text: '2016/12/14')
    expect(term.to_datetime).to eq DateTime.iso8601('2016-12-14')
  end

  it 'returns false if the format is not valid' do
    # From pHD2HWtSA4sEFuvHS.pdf
    term = DateTerm.new(text: '30.2.15')
    expect(term.valid?).to eq false
  end
end
