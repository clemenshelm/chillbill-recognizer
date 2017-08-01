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
      left: 0.12857142857142856,
      right: 0.24615384615384617,
      top: 0.3327820046311611,
      bottom: 0.343367515712868
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Re-Nr:']
  end

  it "detects the invoice number label 'Bon-ID'" do
    # From kvAPgEMmAKgLHBLZf.pdf
    create(
      :word,
      text: 'Bon-ID',
      left: 0.10831151832460734,
      right: 0.2320026178010471,
      top: 0.8708091193562807,
      bottom: 0.8861570555803904
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Bon-ID']
  end

  it "detects the invoice number label 'Rech.Nr:'" do
    # From Thoii6YdqScSdPFZu.pdf
    create(
      :word,
      text: 'Rech.Nr:',
      left: 0.6732090284592738,
      right: 0.7304546941445862,
      top: 0.2509831135785334,
      bottom: 0.2590793430488087
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rech.Nr:']
  end

  it "detects the invoice number label 'Rechnungsnummer:'" do
    # From fHuyd8GiytvSxJhSH.pdf
    create(
      :word,
      text: 'Rechnungsnummer:',
      left: 0.09453712790317305,
      right: 0.22113182859012104,
      top: 0.44377602961591855,
      bottom: 0.45303100416473857
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnungsnummer:']
  end

  it "detects the invoice number label 'Rechnung:'" do
    # From RiAC4eHDe3dHiH7m4.pdf
    create(
      :word,
      text: 'Rechnung:',
      left: 0.06902191691200524,
      right: 0.14753025842329082,
      top: 0.37867221836687487,
      bottom: 0.3897756187832524
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnung:']
  end

  it "detects the invoice number label 'Invoice number:'" do
    # From JzcFZfs2jm8C5eh7b.pdf
    create(
      :word,
      text: 'Invoice',
      left: 0.06871727748691099,
      right: 0.11976439790575916,
      top: 0.9067992599444958,
      bottom: 0.9153561517113784
    )

    create(
      :word,
      text: 'number:',
      left: 0.1263089005235602,
      right: 0.18553664921465968,
      top: 0.9067992599444958,
      bottom: 0.9153561517113784
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Invoice number:']
  end

  it "detects the invoice number label 'Billing ID'" do
    # From GuhNJ5oRyWN5z92Rk.pdf
    create(
      :word,
      text: 'Billing',
      left: 0.06871727748691099,
      right: 0.11125654450261781,
      top: 0.8734967622571693,
      bottom: 0.8843663274745606
    )

    create(
      :word,
      text: 'ID:',
      left: 0.11845549738219895,
      right: 0.13710732984293195,
      top: 0.8734967622571693,
      bottom: 0.8820536540240518
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Billing ID:']
  end

  it "detects the invoice number label 'Rechnung Nr.:'" do
    # From QmCjBsHvE3Rdqwhsd.pdf
    create(
      :word,
      text: 'Rechnung',
      left: 0.20511140235910877,
      right: 0.3761467889908257,
      top: 0.26679796107506953,
      bottom: 0.28255329008341057
    )

    create(
      :word,
      text: 'Nr.:',
      left: 0.4007208387942333,
      right: 0.47771952817824376,
      top: 0.26737720111214086,
      bottom: 0.28058387395736795
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnung Nr.:']
  end

  it "detects the invoice number label 'Rechnungsnummer'" do
    # From Z6vrodr97FEZXXotA.pdf
    create(
      :word,
      text: 'Rechnungsnummer',
      left: 0.28720968269545305,
      right: 0.4435721295387635,
      top: 0.06916493176035161,
      bottom: 0.08026833217672913
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Rechnungsnummer']
  end

  it "detects the invoice number label 'Beleg-Nr.:'" do
    # From 4CodL4nWuXkwcsGQq.pdf
    create(
      :word,
      text: 'Beleg-nr.:',
      left: 0.4273560209424084,
      right: 0.4787303664921466,
      top: 0.24629972247918594,
      bottom: 0.25508788159111934
    )

    invoice_number_labels = InvoiceNumberLabelDetector.filter
    expect(invoice_number_labels.map(&:to_s)).to eq ['Beleg-nr.:']
  end
end
