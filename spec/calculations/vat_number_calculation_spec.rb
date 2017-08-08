# frozen_string_literal: true
require_relative '../../lib/calculations/vat_number_calculation'

describe VatNumberCalculation do
  it 'ignores customer VAT ID numbers' do
    # From 2Q7v8DGnTnYQkBBhA.pdf
    VatNumberTerm.create(
      text: 'ATU64877967',
      left: 0.1655759162303665,
      right: 0.27257853403141363,
      top: 0.2435245143385754,
      bottom: 0.2523126734505088
    )

    VatNumberTerm.create(
      text: 'EU372001951',
      left: 0.8606020942408377,
      right: 0.9633507853403142,
      top: 0.08487511563367253,
      bottom: 0.09366327474560592
    )

    vat_number_calculation = VatNumberCalculation.new(
      customer_vat_number: 'ATU64877967'
    )
    expect(vat_number_calculation.vat_number).to eq 'EU372001951'
  end

  it 'returns nil if there is no vat number' do
    vat_number = VatNumberCalculation.new(customer_vat_number: nil)
    expect(vat_number.vat_number).to be_nil
  end
end
