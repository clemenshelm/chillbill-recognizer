# frozen_string_literal: true
require_relative '../../lib/detectors/invoice_number_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe InvoiceNumberDetector do
  it 'detects common receipt invoice numbers' do
    # From sMMSHJyCdCKvCZ7ra.jpg
    create(
      :word,
      text: '0547-20151202-02-5059',
      left: 0.23821989528795812,
      right: 0.40575916230366493,
      top: 0.2130122713591109,
      bottom: 0.22273674461680945
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq ['0547-20151202-02-5059']
  end

  it 'detects a Spar invoice number' do
    # From kvAPgEMmAKgLHBLZf.jpg
    create(
      :word,
      text: '4144',
      left: 0.1881544502617801,
      right: 0.2683246073298429,
      top: 0.7735061838772165,
      bottom: 0.7885561019222173
    )

    create(
      :word,
      text: '01',
      left: 0.29221204188481675,
      right: 0.3298429319371728,
      top: 0.7732081656981076,
      bottom: 0.7885561019222173
    )

    create(
      :word,
      text: '8597',
      left: 0.3550392670157068,
      right: 0.4352094240837696,
      top: 0.7732081656981076,
      bottom: 0.7881090746535538
    )

    create(
      :word,
      text: '160930',
      left: 0.46138743455497383,
      right: 0.5824607329842932,
      top: 0.7735061838772165,
      bottom: 0.7885561019222173
    )

    create(
      :word,
      text: '1043',
      left: 0.6079842931937173,
      right: 0.6855366492146597,
      top: 0.7739532111458799,
      bottom: 0.7893011473699896
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq [
      '4144 01 8597 160930 1043'
    ]
  end

  it 'detects a DriveNow invoice number' do
    # From Thoii6YdqScSdPFZu.pdf
    create(
      :word,
      text: '9344001433/00/M/00/N',
      left: 0.6601243048740595,
      right: 0.8161596336277396,
      top: 0.22623178348369188,
      bottom: 0.23432801295396716
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq ['9344001433/00/M/00/N']
  end

  it 'detects an A1 invoice number' do
    # From fHuyd8GiytvSxJhSH.pdf
    create(
      :word,
      text: '295133643413',
      left: 0.25253516519463526,
      right: 0.34838076545632973,
      top: 0.44400740397963906,
      bottom: 0.45118000925497453
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq ['295133643413']
  end

  it 'detects an easyname invoice number' do
    # From PTaeSF8Baw7F44FGT.pdf
    create(
      :word,
      text: 'RE0335510',
      left: 0.08766764802093556,
      right: 0.17402682368334968,
      top: 0.31598427018274344,
      bottom: 0.3247744621790423
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['RE0335510']
  end

  it 'detects a Google invoice number' do
    # From JzcFZfs2jm8C5eh7b.pdf
    create(
      :word,
      text: '8640773779761846-5',
      left: 0.6285994764397905,
      right: 0.7915575916230366,
      top: 0.1604995374653099,
      bottom: 0.1690564292321924
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['8640773779761846-5']
  end

  it 'detects an Google billing ID' do
    # From GuhNJ5oRyWN5z92Rk.pdf
    create(
      :word,
      text: '3199-8987-5671',
      left: 0.5521753352960419,
      right: 0.6764802093555774,
      top: 0.13324080499653018,
      bottom: 0.14203099699282906
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['3199-8987-5671']
  end

  it 'detects a Google invoice number with a different number of digits' do
    # From 25owtvtff6GnuZHRo.pdf
    create(
      :word,
      text: '360661687549-10',
      left: 0.6282722513089005,
      right: 0.7630890052356021,
      top: 0.18154486586493987,
      bottom: 0.19010175763182238
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['360661687549-10']
  end

  it 'detects a Hofer invoice number' do
    # From 6bWSXJ7fdLRbtbzaE.pdf
    create(
      :word,
      text: '3521',
      left: 0.007198952879581152,
      right: 0.03599476439790576,
      top: 0.2910395924982635,
      bottom: 0.2986802500578838
    )

    create(
      :word,
      text: '634/092/001/20',
      left: 0.04548429319371728,
      right: 0.1531413612565445,
      top: 0.2910395924982635,
      bottom: 0.29914332021301226
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['3521 634/092/001/20']
  end

  it 'detects a Drei invoice number' do
    # From Z6vrodr97FEZXXotA.pdf
    create(
      :word,
      text: '6117223355',
      left: 0.19136408243375858,
      right: 0.2832842656198888,
      top: 0.014341892204487625,
      bottom: 0.022900763358778626
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['6117223355']
  end

  it 'detects a Drei receipt invoice number' do
    # From 4CodL4nWuXkwcsGQq.pdf
    create(
      :word,
      text: '5873',
      left: 0.48592931937172773,
      right: 0.506217277486911,
      top: 0.24491211840888066,
      bottom: 0.25161887141535616
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['5873']
  end
end
