# frozen_string_literal: true
require_relative '../../lib/calculations/due_date_calculation'

describe DueDateCalculation do
  it 'returns nil if there is no due date' do
    dates = DueDateCalculation.new([])
    expect(dates.due_date).to be_nil
  end

  it "calculates the due date from a bill" do
    skip
    # From 7FDFZnmZmfMyxWZtG.pdf
    create(
      :word,
      text: 'INVOICE',
      left: 4,
      right: 268,
      top: 1229,
      bottom: 1281
    )

    create(
      :word,
      text: 'Date:',
      left: 3,
      right: 126,
      top: 1394,
      bottom: 1433
    )

    create(
      :word,
      text: '30',
      left: 323,
      right: 379,
      top: 1394,
      bottom: 1433
    )

    create(
      :word,
      text: 'April',
      left: 396,
      right: 506,
      top: 1391,
      bottom: 1443
    )

    create(
      :word,
      text: '2015',
      left: 528,
      right: 644,
      top: 1394,
      bottom: 1433
    )

    create(
      :word,
      text: 'Due',
      left: 3,
      right: 94,
      top: 1480,
      bottom: 1519
    )

    create(
      :word,
      text: 'Date:',
      left: 116,
      right: 240,
      top: 1480,
      bottom: 1519
    )

    create(
      :word,
      text: '14',
      left: 338,
      right: 392,
      top: 1480,
      bottom: 1519
    )

    create(
      :word,
      text: 'May',
      left: 413,
      right: 516,
      top: 1480,
      bottom: 1529
    )

    create(
      :word,
      text: '2015',
      left: 534,
      right: 650,
      top: 1480,
      bottom: 1519
    )

    due_date_calculation = DueDateCalculation.new(
      DateTerm.dataset
    )
    expect(due_date_calculation.invoice_date).to eq DateTime.iso8601('2016-03-16')
  end
end
