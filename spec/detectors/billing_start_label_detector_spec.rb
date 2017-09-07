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
      left: 0.450261780104712,
      right: 0.4885471204188482,
      top: 0.2511563367252544,
      bottom: 0.2597132284921369
    )

    create(
      :word,
      text: 'Start:',
      left: 0.49345549738219896,
      right: 0.5258507853403142,
      top: 0.2511563367252544,
      bottom: 0.25809435707678074
    )

    billing_start_labels = BillingStartLabelDetector.filter
    expect(billing_start_labels.map(&:to_s)).to eq ['Billing Start:']
  end

  it 'detects the correct billing start label regex' do
    # From m4F2bLmpKn7wPqM7q.pdf
    create(
      :word,
      text: 'Billing',
      left: 0.450261780104712,
      right: 0.4885471204188482,
      top: 0.2511563367252544,
      bottom: 0.2597132284921369
    )

    create(
      :word,
      text: 'Start:',
      left: 0.49345549738219896,
      right: 0.5258507853403142,
      top: 0.2511563367252544,
      bottom: 0.25809435707678074
    )

    billing_start_labels = BillingStartLabelDetector.filter
    expect(billing_start_labels.map(&:regex)).to eq [BillingStartLabelDetector::BILLING_START_LABELS.to_s]
  end
end
