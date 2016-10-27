# frozen_string_literal: true
require_relative '../../lib/calculations/iban_calculation'

describe IbanCalculation do
  it 'ignores customer VAT ID numbers' do
    IbanTerm.create(
      text: 'AT85 11000 10687868500',
      left: 395,
      right: 717,
      top: 672,
      bottom: 709
    )

    IbanTerm.create(
      text: 'ATU67760915',
      left: 2479,
      right: 2789,
      top: 0,
      bottom: 36
    )

    iban_calculation = IbanCalculation.new(
      IbanTerm.dataset
    )
    expect(iban_calculation.iban).to eq 'AT851100010687868500'
  end
end
