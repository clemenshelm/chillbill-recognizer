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
      left: 0.4093586387434555,
      right: 0.4476439790575916,
      top: 0.17437557816836263,
      bottom: 0.18316373728029603
    )

    create(
      :word,
      text: 'End:',
      left: 0.45287958115183247,
      right: 0.4800392670157068,
      top: 0.17437557816836263,
      bottom: 0.18131359851988899
    )

    billing_end_labels = BillingEndLabelDetector.filter
    expect(billing_end_labels.map(&:to_s)).to eq ['Billing End:']
  end
end
