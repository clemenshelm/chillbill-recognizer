# frozen_string_literal: true
require_relative '../../lib/detectors/invoice_number_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe InvoiceNumberLabelDetector do
  it "detects the invoice number label 'Re-Nr:'" do
    # From sMMSHJyCdCKvCZ7ra.jpg
    create(
      :word,
      text: 'Re-Nr:',
      left: 0.12637362637362637,
      right: 0.24395604395604395,
      top: 0.2609990076083361,
      bottom: 0.271584518690043
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Re-Nr:']
  end
end
