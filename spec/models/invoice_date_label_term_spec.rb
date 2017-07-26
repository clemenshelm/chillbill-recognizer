# frozen_string_literal: true
require_relative '../../lib/boot'

describe InvoiceDateLabelTerm do
  it 'detects a invoice date label correctly' do
    # From cAfvoH3zHjxmp88Ls.pdf
    term = InvoiceDateLabelTerm.new(
      text: 'Rechnungsdatum:',
      left: 0.08213350785340315,
      right: 0.20222513089005237,
      top: 0.45050878815911194,
      bottom: 0.4597594819611471
    )

    expect(term.to_s).to eq 'Rechnungsdatum:'
  end
end
