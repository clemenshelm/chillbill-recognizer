# frozen_string_literal: true
require_relative '../../lib/calculations/due_date_calculation'
require_relative '../support/factory_girl'
require_relative '../factories'

describe DueDateCalculation do
  it 'returns nil if there is no due date' do
    dates = DueDateCalculation.new([])
    expect(dates.due_date).to be_nil
  end

  it 'calculates the due date from a bill' do
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

    DateTerm.create(
      text: '30. April 2015',
      left: 529,
      right: 664,
      top: 1796,
      bottom: 1848
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

    DateTerm.create(
      text: '14 May 2015',
      left: 534,
      right: 650,
      top: 1480,
      bottom: 1519
    )

    due_date_calculation = DueDateCalculation.new(
      DateTerm.dataset
    )

    expect(due_date_calculation.due_date).to eq DateTime.iso8601('2015-05-14')
  end

  it 'calculates the due date when the Zahlungstermin label is used' do
    # From ZkPkwYF8p6PPLbf7f.png
    create(
      :word,
      text: 'Zahlungstermin',
      left: 1558,
      right: 1839,
      top: 274,
      bottom: 317
    )

    create(
      :word,
      text: 'Rechnungsdatum',
      left: 1560,
      right: 1878,
      top: 214,
      bottom: 256
    )

    DateTerm.create(
      text: '10.04.2015',
      left: 2194,
      right: 2397,
      top: 213,
      bottom: 248
    )

    DateTerm.create(
      text: '15.04.2015',
      left: 2194,
      right: 2397,
      top: 274,
      bottom: 309
    )

    due_date_calculation = DueDateCalculation.new(
      DateTerm.dataset
    )

    expect(due_date_calculation.due_date).to eq DateTime.iso8601('2015-04-15')
  end

  it 'does not use a non due-date date' do
    # From BYnCDzw7nNMFergRW.pdf
    create(
      :word,
      text: 'Datum',
      left: 1613,
      right: 1732,
      top: 497,
      bottom: 529
    )

    DateTerm.create(
      text: '16.03.2016',
      left: 1819,
      right: 2026,
      top: 498,
      bottom: 529
    )

    due_date_calculation = DueDateCalculation.new(
      DateTerm.dataset
    )

    expect(due_date_calculation.due_date).to be_nil
  end
end
