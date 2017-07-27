# frozen_string_literal: true
require_relative '../../lib/calculations/relative_date_calculation'
require_relative '../../lib/calculations/date_calculation'

describe RelativeDateCalculation do
  it 'returns the invoice date when the relative date word is prompt' do
    # From ZqMX24iDMxxst5cnP.pdf

    DateTerm.create(
      text: '21.09.2016',
      left: 0.43586387434554974,
      right: 0.5173429319371727,
      top: 0.31521739130434784,
      bottom: 0.32354301572617944
    )

    DateTerm.create(
      text: '21.09.2016',
      left: 0.6164921465968587,
      right: 0.6979712041884817,
      top: 0.31521739130434784,
      bottom: 0.32354301572617944
    )

    DateTerm.create(
      text: '21.09.2016',
      left: 0.8468586387434555,
      right: 0.9283376963350786,
      top: 0.31521739130434784,
      bottom: 0.32354301572617944
    )

    RelativeDateTerm.create(
      text: 'prompt',
      left: 0.21465968586387435,
      right: 0.26472513089005234,
      top: 0.6281221091581869,
      bottom: 0.6382978723404256
    )
    invoice_date = DateCalculation.new.due_date

    relative_date = RelativeDateCalculation.new.relative_date(invoice_date)

    expect(relative_date).to eq invoice_date
  end

  it 'returns nil if there are no relative dates' do
    relative_dates = RelativeDateCalculation.new
    expect(relative_dates.relative_date([])).to be_nil
  end
end
