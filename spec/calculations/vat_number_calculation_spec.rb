require_relative '../../lib/calculations/vat_number_calculation'

describe VatNumberCalculation do
  before(:each) do
    Word.dataset.delete
    PriceTerm.dataset.delete
    BillingPeriodTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete
    CurrencyTerm.dataset.delete
  end

  it "ignores customer VAT ID numbers" do
    VatNumberTerm.create(text: 'ATU67760915', left: 395, right: 717, top: 672, bottom: 709)
    VatNumberTerm.create(text: 'EU372001951', left: 2479, right: 2789, top: 0, bottom: 36)

    vat_number_calculation = VatNumberCalculation.new(
      VatNumberTerm.dataset,
      customer_vat_number: "ATU67760915"
    )
    vat_number_calculation.vat_number

    expect(vat_number_calculation.vat_number).to eq 'EU372001951'
  end
end
