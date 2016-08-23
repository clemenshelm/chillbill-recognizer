require_relative '../../lib/boot'
require_relative '../../lib/detectors/billin_period_detector'
require_relative '../../lib/models/word'
require_relative '../support/factory_girl'
require_relative '../factories'

it "Recognises the billing period from a bill" do
  create(:word, text: T-Mobile, left: 339, right: 599, top: 685, bottom: 740)
  create(:word, text: Rechnung, left: 623, right: 925, top: 685, bottom: 753)
  create(:word, text: Rechnungszeitraum:, left: 206, right: 575, top: 774, bottom: 816)
  create(:word, text: 01.03.2015, left: 591, right: 798, top: 773, bottom: 809)
  create(:word, text: -, left: 809, right: 819, top: 794, bottom: 797)
  create(:word, text: 31.03.2015, left: 832, right: 1038, top: 773, bottom: 809)
  create(:word, text: USt., left: 1856, right: 1931, top: 934, bottom: 970)

  billing_period_numbers = BillingPeriodDetector.filter
  expect(billing_period.map(&:to_s)).to eq ['01.03.2015 - 31.03.2015']
end
