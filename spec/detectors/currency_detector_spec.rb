require_relative '../../lib/boot'
require_relative '../../lib/detectors/currency_detector'
require_relative '../../lib/models/word'
require_relative '../support/factory_girl'
require_relative '../factories'

describe CurrencyDetector do
  before(:each) do
    Word.dataset.delete
    CurrencyTerm.dataset.delete
  end

  it 'recognizes EUR currency on a bill' do
    create(:word, text: 'T', left: 583, right: 602, top: 778, bottom: 817)
    create(:word, text: '€', left: 735, right: 741, top: 790, bottom: 817)
    create(:word, text: 'EUR', left: 777, right: 843, top: 778, bottom: 818)
    create(:word, text: '4,49', left: 943, right: 1037, top: 778, bottom: 824)
    create(:word, text: '17055576', left: 79, right: 264, top: 835, bottom: 880)
    create(:word, text: '023667', left: 292, right: 434, top: 838, bottom: 880)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['EUR']
  end

  it 'recognizes € currency on a bill' do
    create(:word, text: '2,59', left: 730, right: 822, top: 1429, bottom: 1476)
    create(:word, text: 'mie-52.2.0', left: 924, right: 1235, top: 1428, bottom: 1483)
    create(:word, text: 'Betrag', left: 248, right: 391, top: 1550, bottom: 1643)
    create(:word, text: '€', left: 1019, right: 1044, top: 1549, bottom: 1639)
    create(:word, text: '1,18', left: 1091, right: 1185, top: 1549, bottom: 1642)
    create(:word, text: '20%', left: 344, right: 413, top: 1702, bottom: 1744)
    create(:word, text: 'Mwst', left: 439, right: 530, top: 1701, bottom: 1744)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['€']
  end

  it 'recognizes USD currency on a bill' do
    create(:word, text: 'USD', left: 656, right: 797, top: 1190, bottom: 1244)
    create(:word, text: '$140.00', left: 822, right: 1071, top: 1187, bottom: 1250)
    create(:word, text: 'Date', left: 1787, right: 1932, top: 1191, bottom: 1244)
    create(:word, text: 'Paid:', left: 1958, right: 2120, top: 1191, bottom: 1244)
    create(:word, text: '11', left: 2152, right: 2213, top: 1191, bottom: 1242)
    create(:word, text: 'Jun', left: 2245, right: 2364, top: 1191, bottom: 1244)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['USD']
  end

  it 'recognizes $ currency on a bill' do
    create(:word, text: 'USD', left: 656, right: 797, top: 1190, bottom: 1244)
    create(:word, text: '$140.00', left: 822, right: 1071, top: 1187, bottom: 1250)
    create(:word, text: 'Date', left: 1787, right: 1932, top: 1191, bottom: 1244)
    create(:word, text: 'Paid:', left: 1958, right: 2120, top: 1191, bottom: 1244)
    create(:word, text: '11', left: 2152, right: 2213, top: 1191, bottom: 1242)
    create(:word, text: 'Jun', left: 2245, right: 2364, top: 1191, bottom: 1244)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['$']
  end

  it 'recognizes CHF currency on a bill' do
    create(:word, text: 'CHF', left: 708, right: 1147, top: 537, bottom: 689)
    create(:word, text: '16.00', left: 2253, right: 2718, top: 526, bottom: 684)
    create(:word, text: 'Total', left: 162, right: 467, top: 749, bottom: 859)
    create(:word, text: 'EUR', left: 509, right: 803, top: 755, bottom: 861)
    create(:word, text: '15.00', left: 2368, right: 2721, top: 753, bottom: 874)
    create(:word, text: 'Inkl.', left: 156, right: 417, top: 915, bottom: 1027)
    create(:word, text: '8.00%', left: 479, right: 848, top: 921, bottom: 1028)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['CHF']
  end

  it 'regcognizes CNY currency on the bill' do
    create(:word, text: '2', left: 61, right: 86, top: 2687, bottom: 2724)
    create(:word, text: 'rooms', left: 103, right: 243, top: 2697, bottom: 2724)
    create(:word, text: 'CNY', left: 1946, right: 2046, top: 2687, bottom: 2724)
    create(:word, text: '3,685', left: 2061, right: 2179, top: 2687, bottom: 2731)
    create(:word, text: 'CNY', left: 1868, right: 2003, top: 2804, bottom: 2852)
    create(:word, text: '3,685', left: 2022, right: 2178, top: 2805, bottom: 2862)
    create(:word, text: 'g/', left: 1643, right: 1707, top: 2881, bottom: 2939)
    create(:word, text: 'B-eaLEri-Ce-Guaizm-.wi', left: 1730, right: 2181, top: 2887, bottom: 2928)
    create(:word, text: 'Pnce', left: 65, right: 233, top: 2803, bottom: 2857)
    create(:word, text: 'Youlli', left: 61, right: 160, top: 3007, bottom: 3042)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['CNY']
  end

  it 'regcognizes SEK currency on the bill' do
    create(:word, text: 'SEK', left: 842, right: 919, top: 2084, bottom: 2124)
    create(:word, text: 'Moms', left: 28, right: 156, top: 2175, bottom: 2216)
    create(:word, text: '12%', left: 174, right: 261, top: 2175, bottom: 2216)
    create(:word, text: '590.36', left: 675, right: 817, top: 2176, bottom: 2216)
    create(:word, text: 'SEK', left: 842, right: 918, top: 2176, bottom: 2217)
    create(:word, text: 'l', left: 1067, right: 1080, top: 2173, bottom: 2225)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['SEK']
  end

  it 'regcognizes GBP currency on the bill' do
    create(:word, text: '£45.00', left: 2056, right: 2393, top: 4038, bottom: 4160)
    create(:word, text: '4', left: 115, right: 162, top: 4207, bottom: 4323)
    create(:word, text: 'Mineral', left: 226, right: 611, top: 4201, bottom: 4323)
    create(:word, text: 'Water', left: 685, right: 966, top: 4204, bottom: 4323)
    create(:word, text: 'Bettie', left: 1024, right: 1364, top: 4197, bottom: 4319)
    create(:word, text: '£22.00', left: 2056, right: 2393, top: 4201, bottom: 4319)
    create(:word, text: 'w', left: 1, right: 2401, top: 4422, bottom: 4495)
    create(:word, text: 'Amt.Due', left: 685, right: 1080, top: 4526, bottom: 4642)
    create(:word, text: '£564', left: 1545, right: 1983, top: 4523, bottom: 4642)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['GBP']
  end

  it 'regcognizes GBP currency on the bill' do
    create(:word, text: '£45.00', left: 2056, right: 2393, top: 4038, bottom: 4160)
    create(:word, text: '4', left: 115, right: 162, top: 4207, bottom: 4323)
    create(:word, text: 'Mineral', left: 226, right: 611, top: 4201, bottom: 4323)
    create(:word, text: 'Water', left: 685, right: 966, top: 4204, bottom: 4323)
    create(:word, text: 'Bettie', left: 1024, right: 1364, top: 4197, bottom: 4319)
    create(:word, text: '£22.00', left: 2056, right: 2393, top: 4201, bottom: 4319)
    create(:word, text: 'w', left: 1, right: 2401, top: 4422, bottom: 4495)
    create(:word, text: 'Amt.Due', left: 685, right: 1080, top: 4526, bottom: 4642)
    create(:word, text: '£564', left: 1545, right: 1983, top: 4523, bottom: 4642)

    currencies = CurrencyDetector.filter
    expect(currencies.map(&:text)).to eq ['£']
  end
end
