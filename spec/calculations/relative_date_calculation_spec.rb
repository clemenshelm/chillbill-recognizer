# frozen_string_literal: true
require_relative '../../lib/calculations/relative_date_calculation'
require_relative '../../lib/calculations/date_calculation'

describe RelativeDateCalculation do
  it 'returns the invoice date when the relative date word is prompt' do
    # From ZqMX24iDMxxst5cnP.pdf

    DateTerm.create(
      text: '21.09.2016',
      left: 0.3403333333333333,
      right: 0.422,
      top: 0.264075382803298,
      bottom: 0.272791519434629
    )

    DateTerm.create(
      text: '21.09.2016',
      left: 0.5206666666666667,
      right: 0.6026666666666667,
      top: 0.264075382803298,
      bottom: 0.272791519434629
    )

    DateTerm.create(
      text: '21.09.2016',
      left: 0.7513333333333333,
      right: 0.833,
      top: 0.264075382803298,
      bottom: 0.272791519434629
    )

    RelativeDateTerm.create(
      text: 'prompt',
      left: 0.11866666666666667,
      right: 0.16933333333333334,
      top: 0.5769140164899882,
      bottom: 0.5872791519434629
    )
    invoice_date = DateCalculation.new(
      DateTerm.dataset
    ).due_date

    relative_date = RelativeDateCalculation.new(
      RelativeDateTerm.dataset
    ).relative_date(invoice_date)

    expect(relative_date).to eq invoice_date
  end
end
