# frozen_string_literal: true
require_relative '../../lib/calculations/invoice_number_calculation'

describe InvoiceNumberCalculation do
  it 'returns a labelled invoice number of the common shop receipt format' do
    # From 6GiWj7tehdimjcpeA.pdf
    BillDimension.create_image_dimensions(width: 3056, height: 4319)

    InvoiceNumberLabelTerm.create(
      text: 'Re-Nr:',
      left: 0.5009816753926701,
      right: 0.5458115183246073,
      top: 0.35540634406112526,
      bottom: 0.3651308173188238
    )

    InvoiceNumberTerm.create(
      text: '0547-20151202-02-5059',
      left: 0.5569371727748691,
      right: 0.724476439790576,
      top: 0.35540634406112526,
      bottom: 0.3651308173188238
    )

    invoice_number_calculation = InvoiceNumberCalculation.new

    expect(
      invoice_number_calculation.invoice_number
    ).to eq '0547-20151202-02-5059'
  end

  it 'returns nil if there is no invoice number' do
    invoice_number_calculation = InvoiceNumberCalculation.new
    expect(invoice_number_calculation.invoice_number).to be_nil
  end

  it 'returns an invoice number that is below its label' do
    # From Z6vrodr97FEZXXotA.pdf
    BillDimension.create_image_dimensions(width: 3057, height: 4323)

    InvoiceNumberLabelTerm.create(
      text: 'Rechnungsnummer',
      left: 0.28720968269545305,
      right: 0.4435721295387635,
      top: 0.06916493176035161,
      bottom: 0.08026833217672913
    )

    InvoiceNumberTerm.create(
      text: '6117223355',
      left: 0.28655544651619236,
      right: 0.3784756297023225,
      top: 0.08350682396483923,
      bottom: 0.09206569511913024
    )

    invoice_number_calculation = InvoiceNumberCalculation.new

    expect(invoice_number_calculation.invoice_number).to eq '6117223355'
  end

  it 'returns nil if there are unlabelled invoice numbers that need a label' do
    # From Z6vrodr97FEZXXotA.pdf
    InvoiceNumberTerm.create(
      text: '6117223355',
      left: 0.28655544651619236,
      right: 0.3784756297023225,
      top: 0.08350682396483923,
      bottom: 0.09206569511913024,
      needs_label: true
    )

    invoice_number_calculation = InvoiceNumberCalculation.new
    expect(invoice_number_calculation.invoice_number).to be_nil
  end
end
