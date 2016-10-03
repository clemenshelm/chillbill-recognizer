require_relative '../../lib/boot'
require_relative '../../lib/calculations/iban_calculation'
require_relative '../../lib/models/iban_term'

describe IbanCalculation do
  before(:each) do
    IbanTerm.dataset.delete
  end

  it "ignores customer VAT ID numbers" do
    IbanTerm.create(text: 'AT85 11000 10687868500', left: 395, right: 717, top: 672, bottom: 709)
    IbanTerm.create(text: 'ATU67760915', left: 2479, right: 2789, top: 0, bottom: 36)

    iban_calculation = IbanCalculation.new(
      IbanTerm.dataset
    )
    expect(iban_calculation.iban_number).to eq 'AT851100010687868500'
  end
end
