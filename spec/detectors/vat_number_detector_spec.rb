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
  it "recognizes an Austrian VAT ID number" do
    create(:word, text: 'Umsatzsteuer-Identifikotionsnummer:', left: 1487, right: 2118, top: 3849, bottom: 3882)
    create(:word, text: 'ATU19420008', left: 2130, right: 2386, top: 3850, bottom: 3882)
    create(:word, text: 'ARA', left: 2416, right: 2492, top: 3850, bottom: 3881)
    create(:word, text: '94647', left: 2503, right: 2615, top: 3850, bottom: 3882)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU19420008']
  end


  it "recognizes an Austrian VAT ID number" do
    create(:word, text: 'Number:', left: 2272, right: 2458, top: 0, bottom: 36)
    create(:word, text: 'EU372001951', left: 2479, right: 2789, top: 0, bottom: 36)
    create(:word, text: 'summary', left: 79, right: 531, top: 112, bottom: 208)
    create(:word, text: 'Inv0Ice', left: 1501, right: 1669, top: 119, bottom: 156)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['EU372001951']
  end

  it "recognizes an Luxemburg VAT ID number", :focus do
    create( :word, text: 'Umsatzsteueridentifikationsnummer:', left: 1621, right: 2138, top: 2492, bottom: 2516)
    create( :word, text: 'LU20260743', left: 2157, right: 2331, top: 2494, bottom: 2516)
    create( :word, text: 'USt-ID', left: 1151, right: 1244, top: 2527, bottom: 2548)
    create( :word, text: ':', left: 1260, right: 1264, top: 2532, bottom: 2548)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['LU20260743']
  end
end
