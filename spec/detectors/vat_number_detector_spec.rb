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

  it 'recognizes an Austrian VAT ID number seperated by a space', :focus do
    create(:word, text: 'Wien', left: 411, right: 485, top: 267, bottom: 297)
    create(:word, text: 'ATU', left: 298, right: 352, top: 311, bottom: 341)
    create(:word, text: '37893801', left: 374, right: 521, top: 309, bottom: 340)
    create(:word, text: 'EUR', left: 732, right: 787, top: 352, bottom: 382)

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:to_s)).to eq ['ATU37893801']
  end
end
