# frozen_string_literal: true
require_relative '../../lib/detectors/invoice_number_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe InvoiceNumberDetector do
  it 'detects common receipt invoice numbers' do
    # From sMMSHJyCdCKvCZ7ra.jpg
    InvoiceNumberLabelTerm.create(
      text: 'Re-Nr:',
      left: 0.18226439790575916,
      right: 0.22709424083769633,
      top: 0.2130122713591109,
      bottom: 0.22273674461680945
    )



    create(
      :word,
      text: '0547-20151202-02-5059',
      left: 0.23821989528795812,
      right: 0.40575916230366493,
      top: 0.2130122713591109,
      bottom: 0.22273674461680945
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq [
      '0547-20151202-02-5059'
    ]
  end
end
