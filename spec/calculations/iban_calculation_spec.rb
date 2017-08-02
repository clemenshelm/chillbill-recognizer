# frozen_string_literal: true
require_relative '../../lib/calculations/iban_calculation'

describe IbanCalculation do
  it 'ignores customer VAT ID numbers' do
    # From 9NwagojCEgB3Ex92B.pdf
    IbanTerm.create(
      text: 'AT103225000000013300',
      left: 0.4370297677461564,
      right: 0.5763820739286882,
      top: 0.9324543141337035,
      bottom: 0.9382373351839001
    )

    VatNumberTerm.create(
      text: 'ATU62799500',
      left: 0.6781157998037292,
      right: 0.7500817795224076,
      top: 0.9218135554013417,
      bottom: 0.9275965764515383
    )

    iban_calculation = IbanCalculation.new
    expect(iban_calculation.iban).to eq 'AT103225000000013300'
  end

  it 'returns nil if there is no iban' do
    iban = IbanCalculation.new
    expect(iban.iban).to be_nil
  end
end
