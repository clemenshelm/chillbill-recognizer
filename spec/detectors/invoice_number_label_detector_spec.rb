# frozen_string_literal: true
require_relative '../../lib/detectors/invoice_number_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe InvoiceNumberLabelDetector do
  it "detects the invoice number label 'Re-Nr:'" do
    # From sMMSHJyCdCKvCZ7ra.jpg
    create(
      :word,
      text: 'Re-Nr:',
      left: 0.12637362637362637,
      right: 0.24395604395604395,
      top: 0.2609990076083361,
      bottom: 0.271584518690043
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Re-Nr:']
  end

  it "detects the invoice number label 'Bon-ID'" do
    # From kvAPgEMmAKgLHBLZf.jpg
    create(
      :word,
      text: 'Bon-ID',
      left: 0.0,
      right: 0.12369109947643979,
      top: 0.7727611384294442,
      bottom: 0.7881090746535538
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Bon-ID']
  end

  it "detects the invoice number label 'Rech.Nr:'" do
    # From Thoii6YdqScSdPFZu.pdf
    create(
      :word,
      text: 'Rech.Nr:',
      left: 0.5969905135754007,
      right: 0.6542361792607131,
      top: 0.22623178348369188,
      bottom: 0.23432801295396716
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rech.Nr:']
  end

  it "detects the invoice number label 'Rechnungsnummer:'" do
    # From fHuyd8GiytvSxJhSH.pdf
    create(
      :word,
      text: 'Rechnungsnummer:',
      left: 0.09421000981354269,
      right: 0.22080471050049066,
      top: 0.44354465525219805,
      bottom: 0.45279962980101807
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnungsnummer:']
  end

  it "detects the invoice number label 'Rechnung:'" do
    # From RiAC4eHDe3dHiH7m4.pdf
    create(
      :word,
      text: 'Rechnung:',
      left: 0.0016355904481517827,
      right: 0.08014393195943735,
      top: 0.31598427018274344,
      bottom: 0.32708767059912097
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnung:']
  end

  it "detects the invoice number label 'Invoice number:'" do
    # From JzcFZfs2jm8C5eh7b.pdf
    create(
      :word,
      text: 'Invoice',
      left: 0.4342277486910995,
      right: 0.4856020942408377,
      top: 0.1604995374653099,
      bottom: 0.1690564292321924
    )

    create(
      :word,
      text: 'number:',
      left: 0.4918193717277487,
      right: 0.5510471204188482,
      top: 0.1604995374653099,
      bottom: 0.1690564292321924
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Invoice number:']
  end

  it "detects the invoice number label 'Billing ID'" do
    # From GuhNJ5oRyWN5z92Rk.pdf
    create(
      :word,
      text: 'Billing',
      left: 0.37945698397121363,
      right: 0.43016028786391886,
      top: 0.13324080499653018,
      bottom: 0.14457552625491557
    )

    create(
      :word,
      text: 'ID',
      left: 0.43768400392541706,
      right: 0.45305855413804386,
      top: 0.13324080499653018,
      bottom: 0.14203099699282906
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Billing ID']
  end

  it "detects the invoice number label 'Rechnung Nr.:'" do
    # From QmCjBsHvE3Rdqwhsd.pdf
    create(
      :word,
      text: 'Rechnung',
      left: 0.20478374836173002,
      right: 0.37581913499344693,
      top: 0.26656626506024095,
      bottom: 0.28232159406858204
    )

    create(
      :word,
      text: 'Nr.:',
      left: 0.40039318479685454,
      right: 0.477391874180865,
      top: 0.26714550509731233,
      bottom: 0.2803521779425394
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnung Nr.:']
  end

  it "detects the invoice number label 'Rechnungsnummer'" do
    # From Z6vrodr97FEZXXotA.pdf
    create(
      :word,
      text: 'Rechnungsnummer',
      left: 0.1920183186130193,
      right: 0.34838076545632973,
      top: 0.0,
      bottom: 0.011103400416377515
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnungsnummer']
  end

  it "detects the invoice number label 'Beleg-Nr.:'" do
    # From 4CodL4nWuXkwcsGQq.pdf
    create(
      :word,
      text: 'Beleg-nr.:',
      left: 0.4270287958115183,
      right: 0.47840314136125656,
      top: 0.24491211840888066,
      bottom: 0.2537002775208141
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Beleg-nr.:']
  end
end
