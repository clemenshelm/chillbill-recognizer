# frozen_string_literal: true
require_relative '../../lib/calculations/date_calculation'
require_relative '../../lib/detectors/due_date_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe DateCalculation do
  describe '#invoiceDate' do
    it 'returns nil if there is no invoice date candidate' do
      dates = DateCalculation.new
      expect(dates.invoice_date).to be_nil
    end

    it "detects the invoice date labeled with 'Rechnungsdatum:'" do
      # From cAfvoH3zHjxmp88Ls.pdf
      InvoiceDateLabelTerm.create(
        text: 'Rechnungsdatum:',
        left: 0.08213350785340315,
        right: 0.20222513089005237,
        top: 0.45050878815911194,
        bottom: 0.4597594819611471
      )

      DateTerm.create(
        text: '28.10.2016',
        left: 0.2486910994764398,
        right: 0.325261780104712,
        top: 0.45050878815911194,
        bottom: 0.45837187789084183
      )

      invoice_date = DateCalculation.new.invoice_date
      expect(invoice_date).to eq DateTime.iso8601('2016-10-28')
    end

    it 'ignores dates from a billing period if there are other dates' do
      # From ZkPkwYF8p6PPLbf7f.pdf
      start_of_period = DateTerm.create(
        text: '01.03.2015',
        left: 0.27347072293097807,
        right: 0.34216552175335296,
        top: 0.3435114503816794,
        bottom: 0.3518390006939625,
        first_word_id: 24
      )

      end_of_period = DateTerm.create(
        text: '31.03.2015',
        left: 0.35361465489041544,
        right: 0.42230945371279033,
        top: 0.3435114503816794,
        bottom: 0.3518390006939625,
        first_word_id: 26
      )

      DateTerm.create(
        text: '10.04.2015',
        left: 0.8079816813869807,
        right: 0.8753680078508341,
        top: 0.21165857043719638,
        bottom: 0.21998612074947954,
        first_word_id: 13
      )

      BillingPeriodTerm.create(
        from: start_of_period,
        to: end_of_period
      )

      date_calculation = DateCalculation.new.invoice_date
      expect(date_calculation).to eq DateTime.iso8601('2015-04-10')
    end

    it 'takes the end date of the billing period if there are no other dates' do
      # From 98xawHkEKTwMSqdLa.pdf
      start_of_period = DateTerm.create(
        text: '01.02.2016',
        left: 0.2467622571692877,
        right: 0.29995374653098983,
        top: 0.19404450261780104,
        bottom: 0.2054973821989529
      )

      end_of_period = DateTerm.create(
        text: '29.02.2016',
        left: 0.3221554116558742,
        right: 0.37488436632747457,
        top: 0.19404450261780104,
        bottom: 0.2054973821989529
      )

      BillingPeriodTerm.create(
        from: start_of_period,
        to: end_of_period
      )

      date_calculation = DateCalculation.new.invoice_date
      expect(date_calculation).to eq DateTime.iso8601('2016-02-29')
    end

    it 'recognizes the first date as the invoice date' do
      # From 98xawHkEKTwMSqdLa.pdf
      DateTerm.create(
        text: '01.02.2016',
        left: 0.2467622571692877,
        right: 0.29995374653098983,
        top: 0.19404450261780104,
        bottom: 0.2054973821989529
      )

      DateTerm.create(
        text: '29.02.2016',
        left: 0.3221554116558742,
        right: 0.37488436632747457,
        top: 0.19404450261780104,
        bottom: 0.2054973821989529
      )

      date_calculation = DateCalculation.new.invoice_date
      expect(date_calculation).to eq DateTime.iso8601('2016-02-01')
    end

    it 'recognizes first date as a long slash date regex' do
      # From KCsWbyeAvH7RMi2hL.pdf
      DateTerm.create(
        text: '09/17/2013',
        left: 0.14066077854105333,
        right: 0.21524370297677461,
        top: 0.6426092990978487,
        bottom: 0.650705528568124
      )

      date_calculation = DateCalculation.new.invoice_date
      expect(date_calculation).to eq DateTime.iso8601('2013-09-17')
    end
  end

  describe '#dueDate' do
    it 'returns nil if there is no due date' do
      dates = DateCalculation.new.due_date
      expect(dates).to be_nil
    end

    it 'calculates the due date from a bill' do
      # From 7FDFZnmZmfMyxWZtG.pdf
      BillDimension.create_image_dimensions(width: 3056, height: 4324)

      create(
        :word,
        text: 'INVOICE',
        left: 0.12369109947643979,
        right: 0.21106020942408377,
        top: 0.3829787234042553,
        bottom: 0.3952358926919519
      )

      create(
        :word,
        text: 'Date:',
        left: 0.12303664921465969,
        right: 0.16393979057591623,
        top: 0.42206290471785385,
        bottom: 0.4308510638297872
      )

      DateTerm.create(
        text: '30. April 2015',
        left: 0.225130890052356,
        right: 0.34293193717277487,
        top: 0.5166512488436633,
        bottom: 0.5289084181313598
      )

      create(
        :word,
        text: 'Due',
        left: 0.12303664921465969,
        right: 0.15346858638743455,
        top: 0.4424144310823312,
        bottom: 0.45120259019426456
      )

      create(
        :word,
        text: 'Date:',
        left: 0.1606675392670157,
        right: 0.20157068062827224,
        top: 0.4424144310823312,
        bottom: 0.45120259019426456
      )

      DateTerm.create(
        text:  '14 May 2015',
        left: 0.23462041884816753,
        right: 0.33835078534031415,
        top: 0.4421831637372803,
        bottom: 0.45374653098982426
      )

      DueDateLabelDetector.filter
      due_date_calculation = DateCalculation.new.due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2015-05-14')
    end

    it 'calculates the due date when the Zahlungstermin label is used' do
      # From ZkPkwYF8p6PPLbf7f.pdf
      BillDimension.create_image_dimensions(width: 3057, height: 4323)

      DueDateLabelTerm.create(
        text: 'Zahlungstermin',
        left: 0.59633627739614,
        right: 0.6892378148511613,
        top: 0.22600046264168402,
        bottom: 0.2359472588480222
      )

      create(
        :word,
        text: 'Rechnungsdatum',
        left: 0.5969905135754007,
        right: 0.7026496565260059,
        top: 0.21188989127920427,
        bottom: 0.22183668748554244
      )

      DateTerm.create(
        text: '10.04.2015',
        left: 0.8079816813869807,
        right: 0.8753680078508341,
        top: 0.21165857043719638,
        bottom: 0.21998612074947954
      )

      DateTerm.create(
        text: '15.04.2015',
        left: 0.8079816813869807,
        right: 0.8753680078508341,
        top: 0.22576914179967614,
        bottom: 0.2340966921119593
      )

      due_date_calculation = DateCalculation.new.due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2015-04-15')
    end

    it 'does not use a non due-date date' do
      # From BYnCDzw7nNMFergRW.pdf
      create(
        :word,
        text: 'Datum',
        left: 0.618455497382199,
        right: 0.6577225130890052,
        top: 0.16951896392229418,
        bottom: 0.1769195189639223
      )

      DateTerm.create(
        text: '16.03.2016',
        left: 0.68717277486911,
        right: 0.7555628272251309,
        top: 0.16951896392229418,
        bottom: 0.1769195189639223
      )

      due_date_calculation = DateCalculation.new.due_date

      expect(due_date_calculation).to be_nil
    end

    it 'calculates the due date when the Zahlungsziel label is used' do
      # From fGHCBxN6cbksNrHpo.pdf
      BillDimension.create_image_dimensions(width: 3057, height: 4323)

      DueDateLabelTerm.create(
        text: 'Zahlungsziel:',
        left: 0.7085377821393523,
        right: 0.8056918547595682,
        top: 0.32130464954892435,
        bottom: 0.3324080499653019
      )

      DateTerm.create(
        text: '18.10.2016',
        left: 0.8132155708210664,
        right: 0.8946679751390252,
        top: 0.32153597039093224,
        bottom: 0.3300948415452232
      )

      due_date_calculation = DateCalculation.new.due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2016-10-18')
    end

    it 'identifies a due date when "Zahlungstermin" is written above' do
      # From xAkCJuSGM8A4ZGoSy.pdf
      BillDimension.create_image_dimensions(width: 3057, height: 4323)

      DueDateLabelTerm.create(
        text: 'Zahlungstermin',
        left: 0.79816813869807,
        right: 0.8920510304219823,
        top: 0.3395789960675457,
        bottom: 0.34883182974786026
      )

      DateTerm.create(
        text: '2016.11.23.',
        left: 0.6300294406280668,
        right: 0.708210664049722,
        top: 0.36294240111034004,
        bottom: 0.3710386305806153
      )

      DateTerm.create(
        text: '2016.12.09.',
        left: 0.8060189728491985,
        right: 0.8842001962708538,
        top: 0.3624797594263243,
        bottom: 0.3708073097386074
      )

      due_date_calculation = DateCalculation.new.due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2016-12-09')
    end

    it 'calculates the due date when it is written as prompt' do
      # From ZqMX24iDMxxst5cnP.pdf
      BillDimension.create_image_dimensions(width: 3057, height: 4323)

      DateTerm.create(
        text: '21.09.2016',
        left: 0.8468586387434555,
        right: 0.9283376963350786,
        top: 0.31521739130434784,
        bottom: 0.32354301572617944
      )

      DueDateLabelTerm.create(
        text: 'Zahlungsziel:',
        left: 0.09620418848167539,
        right: 0.19208115183246074,
        top: 0.6274283071230342,
        bottom: 0.6382978723404256
      )

      RelativeDateTerm.create(
        text: 'prompt',
        left: 0.21465968586387435,
        right: 0.26472513089005234,
        top: 0.6281221091581869,
        bottom: 0.6382978723404256
      )

      due_date = DateCalculation.new.due_date

      expect(due_date).to eq DateTime.iso8601('2016-09-21')
    end

    it 'calculates the due date when it is written as Fällig nach Erhalt' do
      # From bill 9ynzhWf9nSxTrNmPu.pdf
      BillDimension.create_image_dimensions(width: 3056, height: 4341)

      DateTerm.create(
        text: '2. August 2016',
        left: 0.8183900523560209,
        right: 0.9289921465968587,
        top: 0.27965906473162866,
        bottom: 0.29163787145818937
      )

      RelativeDateTerm.create(
        text: 'Fällig nach Erhalt',
        left: 0.12467277486910995,
        right: 0.25589005235602097,
        top: 0.8682331260078323,
        bottom: 0.8811333794056669
      )

      DueDateLabelTerm.create(
        text: 'Fällig',
        left: 0.12467277486910995,
        right: 0.16295811518324607,
        top: 0.8684634876756507,
        bottom: 0.8799815710665745
      )

      due_date = DateCalculation.new.due_date
      expect(due_date).to eq DateTime.iso8601('2016-08-02')
    end

    it 'calculates the due date when it is written as Fällig bei Erhalt' do
      # Faked example based on 9ynzhWf9nSxTrNmPu.pdf
      # Missing Label - needs Fällig bei Erhalt
      BillDimension.create_image_dimensions(width: 3056, height: 4341)

      DateTerm.create(
        text: '2. August 2016',
        left: 0.8183900523560209,
        right: 0.9289921465968587,
        top: 0.27965906473162866,
        bottom: 0.29163787145818937
      )

      RelativeDateTerm.create(
        text: 'Fällig bei Erhalt',
        left: 0.12467277486910995,
        right: 0.25589005235602097,
        top: 0.8682331260078323,
        bottom: 0.8811333794056669
      )

      DueDateLabelTerm.create(
        text: 'Fällig',
        left: 0.12467277486910995,
        right: 0.16295811518324607,
        top: 0.8684634876756507,
        bottom: 0.8799815710665745
      )
      due_date = DateCalculation.new.due_date
      expect(due_date).to eq DateTime.iso8601('2016-08-02')
    end
  end
end
