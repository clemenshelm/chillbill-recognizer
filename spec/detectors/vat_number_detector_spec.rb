require_relative '../../lib/boot'
require_relative '../../lib/detectors/vat_number_detector'
require_relative '../../lib/models/word'
require_relative '../support/factory_girl'
require_relative '../factories'

describe VatNumberDetector do
  before(:each) do
    Word.dataset.delete
    VatNumberTerm.dataset.delete
  end

  it 'recognizes an Austrian VAT ID number seperated by a space' do
    create(:word, text: 'Wien', left: 411, right: 485, top: 267, bottom: 297)
    create(:word, text: 'ATU', left: 298, right: 352, top: 311, bottom: 341)
    create(:word, text: '37893801', left: 374, right: 521, top: 309, bottom: 340)
    create(:word, text: 'EUR', left: 732, right: 787, top: 352, bottom: 382)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end

  # Bill with two VATs, but this test works because of the data sample
  it "recognizes an Austrian VAT ID number", :focus do
    create(:word, text: 'Umsatzsteuer-Identifikotionsnummer:', left: 1487, right: 2118, top: 3849, bottom: 3882)
    create(:word, text: 'ATU19420008', left: 2130, right: 2386, top: 3850, bottom: 3882)
    create(:word, text: 'ARA', left: 2416, right: 2492, top: 3850, bottom: 3881)
    create(:word, text: '94647', left: 2503, right: 2615, top: 3850, bottom: 3882)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU19420008']
  end


  it "recognizes an EU VAT ID number" do
    create(:word, text: 'Number:', left: 2272, right: 2458, top: 0, bottom: 36)
    create(:word, text: 'EU372001951', left: 2479, right: 2789, top: 0, bottom: 36)
    create(:word, text: 'summary', left: 79, right: 531, top: 112, bottom: 208)
    create(:word, text: 'Inv0Ice', left: 1501, right: 1669, top: 119, bottom: 156)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['EU372001951']
  end

  it "recognizes a Luxemburg VAT ID number" do
    create(:word, text: 'Umsatzsteueridentifikationsnummer:', left: 1621, right: 2138, top: 2492, bottom: 2516)
    create(:word, text: 'LU20260743', left: 2157, right: 2331, top: 2494, bottom: 2516)
    create(:word, text: 'USt-ID', left: 1151, right: 1244, top: 2527, bottom: 2548)
    create(:word, text: ':', left: 1260, right: 1264, top: 2532, bottom: 2548)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['LU20260743']
  end

  it "recognizes a German VAT ID number" do
    create(:word, text: 'USt-ID', left: 1227, right: 1335, top: 2793, bottom: 2820)
    create(:word, text: ':', left: 1353, right: 1357, top: 2800, bottom: 2819)
    create(:word, text: 'DE814584193', left: 1376, right: 1604, top: 2792, bottom: 2819)
    create(:word, text: 'LU-BlO-04', left: 1329, right: 1501, top: 2831, bottom: 2858)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['DE814584193']
  end

  # This test has a large number of samples so it can calculate a realistic median font height
  it "recognizes Irish VAT ID number broken by a line break" do
    create(:word, text: 'Umsatzsteuer-Identitikationsnummer:', left: 1821, right: 2483, top: 368, bottom: 398)
    create(:word, text: 'IE', left: 2500, right: 2534, top: 368, bottom: 398)
    create(:word, text: 'Rec', left: 7, right: 181, top: 362, bottom: 437)
    create(:word, text: 'h', left: 191, right: 239, top: 362, bottom: 435)
    create(:word, text: 'n', left: 253, right: 301, top: 380, bottom: 435)
    create(:word, text: 'u', left: 314, right: 362, top: 382, bottom: 437)
    create(:word, text: 'I1', left: 376, right: 424, top: 380, bottom: 435)
    create(:word, text: '9', left: 434, right: 486, top: 380, bottom: 457)
    create(:word, text: '6388047V', left: 1819, right: 2003, top: 417, bottom: 446)
    create(:word, text: 'Rechnungsempfänger', left: 3, right: 533, top: 628, bottom: 675)
    create(:word, text: 'Rechnungsempfänger', left: 3, right: 533, top: 628, bottom: 675)
    create(:word, text: 'Details', left: 1302, right: 1462, top: 628, bottom: 665)
    create(:word, text: 'Clemens', left: 2, right: 196, top: 699, bottom: 736)
    create(:word, text: 'Helm', left: 216, right: 328, top: 699, bottom: 736)
    create(:word, text: 'Rechnungsnummer:', left: 1302, right: 1749, top: 699, bottom: 745)
    create(:word, text: '321923922866546-5', left: 1885, right: 2347, top: 699, bottom: 736)
    create(:word, text: 'ChillBiII', left: 2, right: 163, top: 770, bottom: 807)
    create(:word, text: 'Ausstellungsdatum:', left: 1298, right: 1735, top: 770, bottom: 817)
    create(:word, text: '30.11.2015', left: 1885, right: 2129, top: 770, bottom: 807)
    create(:word, text: 'Hietzinger', left: 3, right: 228, top: 840, bottom: 887)
    create(:word, text: 'Hauptstraße', left: 244, right: 516, top: 840, bottom: 887)
    create(:word, text: '99A/3', left: 533, right: 661, top: 840, bottom: 877)
    create(:word, text: 'Zahlungsbedingungen:', left: 1300, right: 1807, top: 840, bottom: 887)
    create(:word, text: 'Sofort', left: 1885, right: 2018, top: 840, bottom: 877)
    create(:word, text: 'fällig', left: 2033, right: 2132, top: 840, bottom: 887)
    create(:word, text: '1130', left: 5, right: 106, top: 910, bottom: 947)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['IE6388047V']
  end

  it "recognizes a VAT ID number where number is larger font" do
    create(:word, text: 'Wien', left: 2229, right: 2293, top: 301, bottom: 327)
    create(:word, text: 'ATU', left: 2130, right: 2177, top: 339, bottom: 363)
    create(:word, text: '37893801', left: 2196, right: 2323, top: 338, bottom: 365)
    create(:word, text: 'EUR', left: 2505, right: 2553, top: 379, bottom: 404)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end

end
