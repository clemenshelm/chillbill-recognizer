# frozen_string_literal: true
require_relative '../../lib/calculations/vat_number_calculation'

describe VatNumberCalculation do
  it 'ignores customer VAT ID numbers' do
    VatNumberTerm.create(
      text: 'ATU67760915',
      left: 395,
      right: 717,
      top: 672,
      bottom: 709
    )

    VatNumberTerm.create(
      text: 'EU372001951',
      left: 2479,
      right: 2789,
      top: 0,
      bottom: 36
    )

    vat_number_calculation = VatNumberCalculation.new(
      customer_vat_number: 'ATU67760915'
    )
    vat_number_calculation.vat_number

    expect(vat_number_calculation.vat_number).to eq 'EU372001951'
  end

  it 'returns nil if there is no vat number' do
    vat_number = VatNumberCalculation.new(customer_vat_number: nil)
    expect(vat_number.vat_number).to be_nil
  end
end
