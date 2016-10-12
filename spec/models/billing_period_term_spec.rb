require_relative '../support/factory_girl'
require_relative '../factories'

describe BillingPeriodTerm do
  before(:each) do
    Word.dataset.delete
    PriceTerm.dataset.delete
    BillingPeriodTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete
    CurrencyTerm.dataset.delete
  end

  it "sets the correct values for a billing period" do
    start_of_period = DateTerm.create(
      text: "01.03.2015",
      left: 591,
      right: 798,
      top: 773,
      bottom: 809,
      first_word_id: 19
    )

    end_of_period = DateTerm.create(
      text: "31.03.2015",
      left: 832,
      right: 1038,
      top: 773,
      bottom: 809,
      first_word_id: 26
    )

    billing_period = BillingPeriodTerm.create(
      from: start_of_period,
      to: end_of_period
    )

    expect(billing_period.from).to eq start_of_period
    expect(billing_period.to).to eq end_of_period
  end
end
