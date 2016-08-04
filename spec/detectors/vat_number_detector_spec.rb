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
end
