# frozen_string_literal: true
require_relative '../../lib/boot'

describe InvoiceDateLabelTerm do
  it 'detects a invoice date label correctly' do
    # From cAfvoH3zHjxmp88Ls.pdf
    term = InvoiceDateLabelTerm.new(
      text: 'Rechnungsdatum:',
      left: 0.08115183246073299,
      right: 0.20157068062827224,
      top: 0.44912118408880664,
      bottom: 0.45837187789084183
    )

    expect(term.to_s).to eq 'Rechnungsdatum:'
  end
end
