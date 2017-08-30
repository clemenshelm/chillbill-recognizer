# frozen_string_literal: true
require_relative '../../lib/detectors/invoice_number_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe InvoiceNumberDetector do
  it 'detects common receipt invoice numbers' do
    # From sMMSHJyCdCKvCZ7ra.jpg
    create(
      :word,
      text: '1735-20151014-01-9235',
      left: 0.23821989528795812,
      right: 0.40575916230366493,
      top: 0.2130122713591109,
      bottom: 0.22273674461680945
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq ['1735-20151014-01-9235']
  end

  it 'detects a Spar invoice number' do
    # From kvAPgEMmAKgLHBLZf.pdf
    create(
      :word,
      text: '4144',
      left: 0.2964659685863874,
      right: 0.37663612565445026,
      top: 0.871554164804053,
      bottom: 0.8866040828490538
    )

    create(
      :word,
      text: '01',
      left: 0.4005235602094241,
      right: 0.4381544502617801,
      top: 0.8712561466249441,
      bottom: 0.8866040828490538
    )

    create(
      :word,
      text: '8597',
      left: 0.46335078534031415,
      right: 0.543520942408377,
      top: 0.8712561466249441,
      bottom: 0.8861570555803904
    )

    create(
      :word,
      text: '160930',
      left: 0.5696989528795812,
      right: 0.6907722513089005,
      top: 0.871554164804053,
      bottom: 0.8866040828490538
    )

    create(
      :word,
      text: '1043',
      left: 0.7162958115183246,
      right: 0.793848167539267,
      top: 0.8720011920727164,
      bottom: 0.8873491282968261
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
      left: 0.7363428197579326,
      right: 0.8923781485116127,
      top: 0.2509831135785334,
      bottom: 0.2590793430488087
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq ['9344001433/00/M/00/N']
  end

  it 'detects an A1 invoice number' do
    # From fHuyd8GiytvSxJhSH.pdf
    create(
      :word,
      text: '295133643413',
      left: 0.25286228328426563,
      right: 0.3487078835459601,
      top: 0.44423877834335956,
      bottom: 0.45141138361869504
    )

    invoice_numbers = InvoiceNumberDetector.filter

    expect(invoice_numbers.map(&:to_s)).to eq ['295133643413']
  end

  it 'detects an easyname invoice number' do
    # From PTaeSF8Baw7F44FGT.pdf
    create(
      :word,
      text: 'RE0337923',
      left: 0.155053974484789,
      right: 0.24141315014720313,
      top: 0.37867221836687487,
      bottom: 0.38746241036317375
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['RE0337923']
  end

  it 'detects a Google invoice number' do
    # From JzcFZfs2jm8C5eh7b.pdf
    create(
      :word,
      text: '8640773779761846-5',
      left: 0.20451570680628273,
      right: 0.36747382198952877,
      top: 0.9067992599444958,
      bottom: 0.9153561517113784
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['8640773779761846-5']
  end

  it 'detects an Google billing ID' do
    # From GuhNJ5oRyWN5z92Rk.pdf
    create(
      :word,
      text: '8761-4080-2361',
      left: 0.20451570680628273,
      right: 0.3239528795811518,
      top: 0.8734967622571693,
      bottom: 0.8820536540240518
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['8761-4080-2361']
  end

  it 'detects a Google invoice number with more digits' do
    # From GuhNJ5oRyWN5z92Rk.pdf
    create(
      :word,
      text: '9377396032481092-46',
      left: 0.20451570680628273,
      right: 0.3769633507853403,
      top: 0.8901480111008325,
      bottom: 0.8987049028677151
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['9377396032481092-46']
  end

  it 'detects a Google invoice number with fewer digits' do
    # From 25owtvtff6GnuZHRo.pdf
    create(
      :word,
      text: '360661687549-10',
      left: 0.6960078534031413,
      right: 0.830824607329843,
      top: 0.20143385753931545,
      bottom: 0.20999074930619796
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['360661687549-10']
  end

  it 'detects a Hofer invoice number' do
    # From 6bWSXJ7fdLRbtbzaE.pdf
    create(
      :word,
      text: '3521',
      left: 0.6233638743455497,
      right: 0.6521596858638743,
      top: 0.32993748552905766,
      bottom: 0.33757814308867795
    )

    create(
      :word,
      text: '634/092/001/20',
      left: 0.6616492146596858,
      right: 0.7693062827225131,
      top: 0.32993748552905766,
      bottom: 0.3380412132438064
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['3521 634/092/001/20']
  end

  it 'detects a Drei invoice number' do
    # From Z6vrodr97FEZXXotA.pdf
    create(
      :word,
      text: '6117223355',
      left: 0.28655544651619236,
      right: 0.3784756297023225,
      top: 0.08350682396483923,
      bottom: 0.09206569511913024
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['6117223355']
  end

  it 'detects a Drei receipt invoice number' do
    # From 4CodL4nWuXkwcsGQq.pdf
    create(
      :word,
      text: '5873',
      left: 0.4862565445026178,
      right: 0.506544502617801,
      top: 0.24629972247918594,
      bottom: 0.2530064754856614
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['5873']
  end

  it 'detects made up of just 5 digits' do
    # From vYkPiDkrvZte3Jn2S.PDF
    create(
      :word,
      text: '26347',
      left: 0.6946989528795812,
      right: 0.7447643979057592,
      top: 0.1604995374653099,
      bottom: 0.16975023126734506
    )

    invoice_numbers = InvoiceNumberDetector.filter
    expect(invoice_numbers.map(&:to_s)).to eq ['26347']
  end
end
