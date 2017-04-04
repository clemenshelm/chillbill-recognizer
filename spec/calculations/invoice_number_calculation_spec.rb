# frozen_string_literal: true
require_relative '../../lib/calculations/invoice_number_calculation'

describe InvoiceNumberCalculation do
  it 'returns a labelled invoice number of the common shop receipt format' do
    InvoiceNumberLabelTerm.create(
      text: 'Re-Nr:',
      left: 0.18226439790575916,
      right: 0.22709424083769633,
      top: 0.2130122713591109,
      bottom: 0.22273674461680945
    )

    InvoiceNumberTerm.create(
      text: '0547-20151202-02-5059',
      left: 0.23821989528795812,
      right: 0.40575916230366493,
      top: 0.2130122713591109,
      bottom: 0.22273674461680945
    )

    invoice_number_calculation = InvoiceNumberCalculation.new

    expect(
      invoice_number_calculation.invoice_number
    ).to eq '0547-20151202-02-5059'
  end

  it 'returns nil if there is no invoice number' do
    invoice_number = InvoiceNumberCalculation.new
    expect(invoice_number.invoice_number).to be_nil
  end

  it 'returns an invoice number that is below its label' do
    # From Z6vrodr97FEZXXotA.pdf
    InvoiceNumberLabelTerm.create(
      text: 'Rechnungsnummer',
      left: 0.1920183186130193,
      right: 0.34838076545632973,
      top: 0.0,
      bottom: 0.011103400416377515
    )

    InvoiceNumberTerm.create(
      text: '6117223355',
      left: 0.19136408243375858,
      right: 0.2832842656198888,
      top: 0.014341892204487625,
      bottom: 0.022900763358778626
    )

    invoice_number_calculation = InvoiceNumberCalculation.new

    expect(invoice_number_calculation.invoice_number).to eq '6117223355'
  end

  it 'returns nil if there are unlabelled invoice numbers that need a label' do
    InvoiceNumberTerm.create(
      text: '6117223355',
      left: 0.19136408243375858,
      right: 0.2832842656198888,
      top: 0.014341892204487625,
      bottom: 0.022900763358778626,
      needs_label: true
    )

    invoice_number_calculation = InvoiceNumberCalculation.new
    expect(invoice_number_calculation.invoice_number).to be_nil
  end
end
