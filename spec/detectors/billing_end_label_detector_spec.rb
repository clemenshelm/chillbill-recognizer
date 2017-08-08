# frozen_string_literal: true
require_relative '../../lib/detectors/billing_end_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe BillingEndLabelDetector do
  it "detects the billing end label 'Billing End:'" do
    # From m4F2bLmpKn7wPqM7q.pdf
    create(
      :word,
      text: 'Billing',
      left: 0.450261780104712,
      right: 0.4885471204188482,
      top: 0.26595744680851063,
      bottom: 0.27451433857539315
    )

    create(
      :word,
      text: 'End:',
      left: 0.493782722513089,
      right: 0.5209424083769634,
      top: 0.26595744680851063,
      bottom: 0.272895467160037
    )

    billing_end_labels = BillingEndLabelDetector.filter
    expect(billing_end_labels.map(&:to_s)).to eq ['Billing End:']
  end
end
