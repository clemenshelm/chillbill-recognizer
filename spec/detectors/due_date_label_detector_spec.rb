# frozen_string_literal: true
require_relative '../../lib/detectors/due_date_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe DueDateLabelDetector do
  it "detects the due date label 'Zahlungstermin'" do
    # From ZkPkwYF8p6PPLbf7f.png
    create(
      :word,
      text: 'Wien',
      left: 0.102,
      right: 0.13233333333333333,
      top: 0.07752120640904807,
      bottom: 0.08553251649387371
    )

    create(
      :word,
      text: 'Zahlungstermin',
      left: 0.5193333333333333,
      right: 0.613,
      top: 0.0645617342130066,
      bottom: 0.07469368520263903
    )

    create(
      :word,
      text: 'Ihre',
      left: 0.06966666666666667,
      right: 0.106,
      top: 0.16140433553251649,
      bottom: 0.17436380772855797
    )

    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['Zahlungstermin']
  end

  it "detects the due date label 'Zahlungsziel:'" do
    # From fGHCBxN6cbksNrHpo.pdf
    create(
      :word,
      text: 'Zahlungsziel:',
      left: 0.613,
      right: 0.7106666666666667,
      top: 0.15339302544769085,
      bottom: 0.16470311027332704
    )

    create(
      :word,
      text: '18.10.2016',
      left: 0.718,
      right: 0.7993333333333333,
      top: 0.1536286522148916,
      bottom: 0.1623468426013195
    )

    create(
      :word,
      text: 'Kunden',
      left: 0.5523333333333333,
      right: 0.608,
      top: 0.16823751178133836,
      bottom: 0.177191328934967
    )

    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['Zahlungsziel:']
  end

  it "detects the due date label 'Due Date:'" do
    # From 7FDFZnmZmfMyxWZtG.pdf
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
      text: '14 May 2015',
      left: 534,
      right: 650,
      top: 1480,
      bottom: 1519
    )
  end
end
