# frozen_string_literal: true
require_relative '../../lib/detectors/invoice_date_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe InvoiceDateLabelDetector do
  it "detects the invoice date label 'Rechnungsdatum:'" do
    # From cAfvoH3zHjxmp88Ls.pdf
    create(
      :word,
      text: 'Rechnungsdatum:',
      left: 0.08115183246073299,
      right: 0.20157068062827224,
      top: 0.44912118408880664,
      bottom: 0.45837187789084183
    )

    create(
      :word,
      text: 'I',
      left: 0.23756544502617802,
      right: 0.23821989528795812,
      top: 0.4588344125809436,
      bottom: 0.4592969472710453
    )

    create(
      :word,
      text: '28.10.2016',
      left: 0.24770942408376964,
      right: 0.324934554973822,
      top: 0.44912118408880664,
      bottom: 0.4569842738205365
    )

    invoice_date_labels = InvoiceDateLabelDetector.filter
    expect(invoice_date_labels.map(&:to_s)).to eq ['Rechnungsdatum:']
  end
end
