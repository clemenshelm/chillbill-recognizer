require_relative '../../lib/detectors/date_detector'
require_relative '../../lib/detectors/billing_period_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe BillingPeriodDetector do
  it "Recognises the billing period from a bill" do
    create(:word, text: 'T-Mobile', left: 339, right: 599, top: 685, bottom: 740)
    create(:word, text: 'Rechnung', left: 623, right: 925, top: 685, bottom: 753)
    create(:word, text: 'Rechnungszeitraum:', left: 206, right: 575, top: 774, bottom: 816)
    create(:word, text: '01.03.2015', left: 591, right: 798, top: 773, bottom: 809)
    create(:word, text: '-', left: 809, right: 819, top: 794, bottom: 797)
    create(:word, text: '31.03.2015', left: 832, right: 1038, top: 773, bottom: 809)
    create(:word, text: 'USt.', left: 1856, right: 1931, top: 934, bottom: 970)

    dates = DateDetector.filter
    billing_periods = BillingPeriodDetector.filter
    expect(billing_periods.map(&:from)).to eq [dates.first]
    expect(billing_periods.map(&:to)).to eq [dates.last]
  end

  it "Recognizes a billing period seperated by the word 'bis' " do
    create(:word, text: '07.02.2016', left: 648, right: 913, top: 1148, bottom: 1190)
    create(:word, text: 'bis', left: 938, right: 1000, top: 1146, bottom: 1189)
    create(:word, text: '10.03.2016', left: 1026, right: 1288, top: 1148, bottom: 1190)
    create(:word, text: 'Gesamtbetragfbruttoj', left: 1348, right: 1948, top: 1240, bottom: 1301)
    create(:word, text: '1000,-', left: 2145, right: 2291, top: 1244, bottom: 1293)

    dates = DateDetector.filter
    billing_periods = BillingPeriodDetector.filter
    expect(billing_periods.map(&:from)).to eq [dates.first]
    expect(billing_periods.map(&:to)).to eq [dates.last]
  end

  it "it doesn't consider other dates as part of the billing period" do
    create(:word, text: 'Ausstellungsdatum:', left: 1298, right: 1735, top: 770, bottom: 817)
    create(:word, text: '30.11.2015', left: 1885, right: 2129, top: 770, bottom: 807)
    create(:word, text: 'EUR:', left: 1747, right: 1860, top: 1508, bottom: 1545)
    create(:word, text: 'Work', left: 269, right: 393, top: 1194, bottom: 1230)
    create(:word, text: '01.11.2015', left: 1301, right: 1546, top: 1194, bottom: 1230)
    create(:word, text: '-', left: 1565, right: 1580, top: 1214, bottom: 1221)
    create(:word, text: '30.11.2015', left: 1595, right: 1840, top: 1194, bottom: 1230)

    DateDetector.filter
    billing_periods = BillingPeriodDetector.filter
    expect(billing_periods.first.from.to_datetime).to eq DateTime.iso8601('2015-11-01')
    expect(billing_periods.first.to.to_datetime).to eq DateTime.iso8601('2015-11-30')
  end
end
