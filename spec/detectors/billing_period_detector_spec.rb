# frozen_string_literal: true
require_relative '../../lib/detectors/date_detector'
require_relative '../../lib/detectors/billing_period_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe BillingPeriodDetector do
  it 'Recognises the billing period from a bill' do
    # From ZkPkwYF8p6PPLbf7f.pdf
    BillDimension.create_image_dimensions(width: 3057, height: 4323)

    create(
      :word,
      text: 'Rechnungszeitraum:',
      left: 0.14556754988550866,
      right: 0.26856395158652274,
      top: 0.34374277122368724,
      bottom: 0.35368956743002544
    )

    create(
      :word,
      text: '01.03.2015',
      left: 0.27347072293097807,
      right: 0.34216552175335296,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625
    )

    create(
      :word,
      text: '-',
      left: 0.3464180569185476,
      right: 0.3496892378148512,
      top: 0.34836918806384454,
      bottom: 0.34906315058986814
    )

    create(
      :word,
      text: '31.03.2015',
      left: 0.35361465489041544,
      right: 0.42230945371279033,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625
    )

    dates = DateDetector.filter
    billing_periods = BillingPeriodDetector.filter
    expect(billing_periods.map(&:from)).to eq [dates.first]
    expect(billing_periods.map(&:to)).to eq [dates.last]
  end

  it "Recognizes a billing period seperated by the word 'bis' " do
    # Missing label - needs bis
    BillDimension.create_image_dimensions(width: 3057, height: 4323)

    create(
      :word,
      text: '07.02.2016',
      left: 648,
      right: 913,
      top: 1148,
      bottom: 1190
    )

    create(
      :word,
      text: 'bis',
      left: 938,
      right: 1000,
      top: 1146,
      bottom: 1189
    )

    create(
      :word,
      text: '10.03.2016',
      left: 1026,
      right: 1288,
      top: 1148,
      bottom: 1190
    )

    create(
      :word,
      text: 'Gesamtbetragfbruttoj',
      left: 1348,
      right: 1948,
      top: 1240,
      bottom: 1301
    )

    create(
      :word,
      text: '1000,-',
      left: 2145,
      right: 2291,
      top: 1244,
      bottom: 1293
    )

    dates = DateDetector.filter
    billing_periods = BillingPeriodDetector.filter
    expect(billing_periods.map(&:from)).to eq [dates.first]
    expect(billing_periods.map(&:to)).to eq [dates.last]
  end

  it "it doesn't consider other dates as part of the billing period" do
    # No idea what bill this comes from. Guessing dimensions ...
    BillDimension.create_image_dimensions(width: 3057, height: 4323)

    create(
      :word,
      text: 'Zahlungstermin',
      left: 0.59633627739614,
      right: 0.6892378148511613,
      top: 0.22600046264168402,
      bottom: 0.2359472588480222
    )

    create(
      :word,
      text: '13.04.2016',
      left: 0.8079816813869807,
      right: 0.8756951259404645,
      top: 0.22576914179967614,
      bottom: 0.2340966921119593
    )

    create(
      :word,
      text: 'Rechnungszeitraum:',
      left: 0.14556754988550866,
      right: 0.26856395158652274,
      top: 0.34374277122368724,
      bottom: 0.35368956743002544
    )

    create(
      :word,
      text: '01.03.2016',
      left: 0.27347072293097807,
      right: 0.34249263984298334,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625
    )

    create(
      :word,
      text: '-',
      left: 0.3464180569185476,
      right: 0.3496892378148512,
      top: 0.34836918806384454,
      bottom: 0.34906315058986814
    )

    create(
      :word,
      text: '31.03.2016',
      left: 0.35361465489041544,
      right: 0.42263657180242065,
      top: 0.3435114503816794,
      bottom: 0.3518390006939625
    )

    DateDetector.filter
    billing_periods = BillingPeriodDetector.filter

    expect(billing_periods.first.from.to_datetime).to eq DateTime.iso8601(
      '2016-03-01'
    )

    expect(billing_periods.first.to.to_datetime).to eq DateTime.iso8601(
      '2016-03-31'
    )
  end

  it 'prefers from dates closer to the separator' do
    # From 3EagyvJYF2RJhNTQC.pdf
    BillDimension.create_image_dimensions(width: 3056, height: 4324)

    create(
      :word,
      text: '01.06.2016',
      left: 0.07395287958115183,
      right: 0.16393979057591623,
      top: 0.22664199814986125,
      bottom: 0.23566142460684553
    )

    create(
      :word,
      text: '(01.05.2016',
      left: 0.07984293193717278,
      right: 0.17670157068062828,
      top: 0.40564292321924145,
      bottom: 0.41720629047178537
    )

    create(
      :word,
      text: '-',
      left: 0.18259162303664922,
      right: 0.18848167539267016,
      top: 0.4114246068455134,
      bottom: 0.4128122109158187
    )

    create(
      :word,
      text: '31.05.2016)',
      left: 0.1943717277486911,
      right: 0.29090314136125656,
      top: 0.40564292321924145,
      bottom: 0.41720629047178537
    )

    DateDetector.filter
    billing_periods = BillingPeriodDetector.filter

    expect(billing_periods.first.from.to_datetime).to eq DateTime.iso8601(
      '2016-05-01'
    )
  end

  it 'detects the billing period using billing period labels' do
    # From m4F2bLmpKn7wPqM7q.pdf
    BillDimension.create_image_dimensions(width: 3057, height: 4323)

    BillingStartLabelTerm.create(
      text: 'Billing Start:',
      left: 0.450261780104712,
      right: 0.5258507853403142,
      top: 0.2511563367252544,
      bottom: 0.259713228492136
    )

    DateTerm.create(
      text: '22 October 2016',
      left: 0.5517015706806283,
      right: 0.6479057591623036,
      top: 0.2511563367252544,
      bottom: 0.2578630897317299
    )

    BillingEndLabelTerm.create(
      text: 'Billing End:',
      left: 0.450261780104712,
      right: 0.5209424083769634,
      top: 0.26595744680851063,
      bottom: 0.27451433857539315
    )

    DateTerm.create(
      text: '27 October 2016',
      left: 0.5517015706806283,
      right: 0.6479057591623036,
      top: 0.26595744680851063,
      bottom: 0.27266419981498613
    )

    billing_periods = BillingPeriodDetector.filter

    expect(billing_periods.first.from.to_datetime).to eq DateTime.iso8601(
      '2016-10-22'
    )
    expect(billing_periods.first.to.to_datetime).to eq DateTime.iso8601(
      '2016-10-27'
    )
  end

  it 'detects the correct vat regex' do
    # From test above
    create(
      :word,
      text: 'ATU',
      left: 0.42424242424242425,
      right: 0.48484848484848486,
      top: 0.19330855018587362,
      bottom: 0.2073523337463858
    )

    create(
      :word,
      text: '69210837',
      left: 0.51010101010101,
      right: 0.6747474747474748,
      top: 0.19330855018587362,
      bottom: 0.2077653862040479
    )

    vat_numbers = VatNumberDetector.filter
    expect(vat_numbers.map(&:regex)).to eq [VatNumberDetector::VAT_REGEX.to_s]
  end
end
