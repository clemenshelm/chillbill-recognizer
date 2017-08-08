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
      left: 0.08213350785340315,
      right: 0.20222513089005237,
      top: 0.45050878815911194,
      bottom: 0.4597594819611471
    )

    create(
      :word,
      text: '295135522536',
      left: 0.2486910994764398,
      right: 0.34914921465968585,
      top: 0.4391766882516189,
      bottom: 0.44680851063829785
    )

    create(
      :word,
      text: '28.10.2016',
      left: 0.2486910994764398,
      right: 0.325261780104712,
      top: 0.45050878815911194,
      bottom: 0.45837187789084183
    )

    invoice_date_labels = InvoiceDateLabelDetector.filter
    expect(invoice_date_labels.map(&:to_s)).to eq ['Rechnungsdatum:']
  end
end
