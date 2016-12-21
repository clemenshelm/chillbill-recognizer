# frozen_string_literal: true
require_relative '../../lib/detectors/billing_start_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe BillingStartLabelDetector do
  it "detects the billing start label 'Billing Start:'" do
    # From m4F2bLmpKn7wPqM7q.pdf
    create(
      :word,
      text: 'Billing',
      left: 0.4093586387434555,
      right: 0.4476439790575916,
      top: 0.1595744680851064,
      bottom: 0.1683626271970398
    )

    create(
      :word,
      text: 'Start:',
      left: 0.4525523560209424,
      right: 0.4849476439790576,
      top: 0.1593432007400555,
      bottom: 0.16651248843663274
    )

    billing_start_labels = BillingStartLabelDetector.filter
    expect(billing_start_labels.map(&:to_s)).to eq ['Billing Start:']
  end
end
