# frozen_string_literal: true
require_relative '../../lib/calculations/date_calculation'
require_relative '../../lib/detectors/due_date_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe DateCalculation do
  describe '#invoiceDate' do
    it 'returns nil if there is no invoice date candidate' do
      dates = DateCalculation.new([])
      expect(dates.invoice_date).to be_nil
    end

    it "detects the invoice date labeled with 'Rechnungsdatum:'" do
      # From cAfvoH3zHjxmp88Ls.pdf
      InvoiceDateLabelTerm.create(
        text: 'Rechnungsdatum:',
        left: 0.08115183246073299,
        right: 0.20157068062827224,
        top: 0.44912118408880664,
        bottom: 0.45837187789084183
      )

      create(
        :word,
        text: 'I',
        left: 0.23756544502617802,
        right: 0.23821989528795812,
        top: 0.4588344125809436,
        bottom: 0.4592969472710453
      )

      DateTerm.create(
        text: '28.10.2016',
        left: 0.24770942408376964,
        right: 0.324934554973822,
        top: 0.44912118408880664,
        bottom: 0.4569842738205365
      )

      invoice_date = DateCalculation.new(
        DateTerm.dataset
      ).invoice_date

      expect(invoice_date).to eq DateTime.iso8601('2016-10-28')
    end

    it 'ignores dates from a billing period if there are other dates' do
      start_of_period = DateTerm.create(
        text: '01.03.2015',
        left: 591,
        right: 798,
        top: 773,
        bottom: 809,
        first_word_id: 19
      )

      end_of_period = DateTerm.create(
        text: '31.03.2015',
        left: 832,
        right: 1038,
        top: 773,
        bottom: 809,
        first_word_id: 26
      )

      DateTerm.create(
        text: '10.04.2015',
        left: 2194,
        right: 2397,
        top: 213,
        bottom: 248,
        first_word_id: 40
      )

      BillingPeriodTerm.create(
        from: start_of_period,
        to: end_of_period
      )

      date_calculation = DateCalculation.new(
        DateTerm.dataset
      )
      expect(date_calculation.invoice_date).to eq DateTime.iso8601('2015-04-10')
    end

    it 'takes the end date of the billing period if there are no other dates' do
      # From 98xawHkEKTwMSqdLa.pdf
      start_of_period = DateTerm.create(
        text: '01.02.2016',
        left: 0.1822386679000925,
        right: 0.23543015726179464,
        top: 0.12369109947643979,
        bottom: 0.1354712041884817
      )

      end_of_period = DateTerm.create(
        text: '29.02.2016',
        left: 0.2574005550416281,
        right: 0.31036077705827936,
        top: 0.12369109947643979,
        bottom: 0.1354712041884817
      )

      BillingPeriodTerm.create(
        from: start_of_period,
        to: end_of_period
      )

      date_calculation = DateCalculation.new(
        DateTerm.dataset
      )
      expect(date_calculation.invoice_date).to eq DateTime.iso8601('2016-02-29')
    end

    it 'recognizes the first date as the invoice date' do
      DateTerm.create(
        text: '16.03.2016',
        left: 1819,
        right: 2026,
        top: 498,
        bottom: 529
      )

      DateTerm.create(
        text: '21.03.2016',
        left: 1816,
        right: 2026,
        top: 586,
        bottom: 618
      )

      date_calculation = DateCalculation.new(
        DateTerm.dataset
      )
      expect(date_calculation.invoice_date).to eq DateTime.iso8601('2016-03-16')
    end

    it 'recognizes first date as a long slash date regex' do
      DateTerm.create(
        text: '13/08/2016',
        left: 1819,
        right: 2026,
        top: 498,
        bottom: 529
      )

      date_calculation = DateCalculation.new(
        DateTerm.dataset
      )
      expect(date_calculation.invoice_date).to eq DateTime.iso8601('2016-08-13')
    end
  end

  describe '#dueDate' do
    it 'returns nil if there is no due date' do
      dates = DateCalculation.new([]).due_date
      expect(dates).to be_nil
    end

    it 'calculates the due date from a bill' do
      # From 7FDFZnmZmfMyxWZtG.pdf
      create(
        :word,
        text: 'INVOICE',
        left: 4,
        right: 268,
        top: 1229,
        bottom: 1281
      )

      create(
        :word,
        text: 'Date:',
        left: 3,
        right: 126,
        top: 1394,
        bottom: 1433
      )

      DateTerm.create(
        text: '30. April 2015',
        left: 529,
        right: 664,
        top: 1796,
        bottom: 1848
      )

      create(
        :word,
        text: 'Due',
        left: 3,
        right: 94,
        top: 1480,
        bottom: 1519
      )

      create(
        :word,
        text: 'Date:',
        left: 116,
        right: 240,
        top: 1480,
        bottom: 1519
      )

      DateTerm.create(
        text: '14 May 2015',
        left: 534,
        right: 650,
        top: 1480,
        bottom: 1519
      )

      DueDateLabelDetector.filter
      due_date_calculation = DateCalculation.new(
        DateTerm.dataset
      )

      expect(due_date_calculation.due_date).to eq DateTime.iso8601('2015-05-14')
    end

    it 'calculates the due date when the Zahlungstermin label is used' do
      # From ZkPkwYF8p6PPLbf7f.png
      DueDateLabelTerm.create(
        text: 'Zahlungstermin',
        left: 1558,
        right: 1839,
        top: 274,
        bottom: 317
      )

      create(
        :word,
        text: 'Rechnungsdatum',
        left: 1560,
        right: 1878,
        top: 214,
        bottom: 256
      )

      DateTerm.create(
        text: '10.04.2015',
        left: 2194,
        right: 2397,
        top: 213,
        bottom: 248
      )

      DateTerm.create(
        text: '15.04.2015',
        left: 2194,
        right: 2397,
        top: 274,
        bottom: 309
      )

      due_date_calculation = DateCalculation.new(
        DateTerm.dataset
      ).due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2015-04-15')
    end

    it 'does not use a non due-date date' do
      # From BYnCDzw7nNMFergRW.pdf
      create(
        :word,
        text: 'Datum',
        left: 1613,
        right: 1732,
        top: 497,
        bottom: 529
      )

      DateTerm.create(
        text: '16.03.2016',
        left: 1819,
        right: 2026,
        top: 498,
        bottom: 529
      )

      due_date_calculation = DateCalculation.new(
        DateTerm.dataset
      ).due_date

      expect(due_date_calculation).to be_nil
    end

    it 'calculates the due date when the Zahlungsziel label is used' do
      # From fGHCBxN6cbksNrHpo.pdf
      DueDateLabelTerm.create(
        text: 'Zahlungsziel:',
        left: 1839,
        right: 2132,
        top: 651,
        bottom: 699
      )

      DateTerm.create(
        text: '18.10.2016',
        left: 2154,
        right: 2398,
        top: 652,
        bottom: 689
      )

      due_date_calculation = DateCalculation.new(
        DateTerm.dataset
      ).due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2016-10-18')
    end

    it 'identifies a due date when "Zahlungstermin" is written above' do
      # From xAkCJuSGM8A4ZGoSy.pdf
      DueDateLabelTerm.create(
        text: 'Zahlungstermin',
        left: 0.7877003598298986,
        right: 0.8815832515538109,
        top: 0.2933148276659727,
        bottom: 0.30279898218829515
      )

      DateTerm.create(
        text: '2016.11.23.',
        left: 0.6195616617598954,
        right: 0.6977428851815506,
        top: 0.31690955355077494,
        bottom: 0.32523710386305804
      )

      DateTerm.create(
        text: '2016.12.09.',
        left: 0.7955511939810271,
        right: 0.8740595354923127,
        top: 0.3164469118667592,
        bottom: 0.3250057830210502
      )

      due_date_calculation = DateCalculation.new(
        DateTerm.dataset
      ).due_date

      expect(due_date_calculation).to eq DateTime.iso8601('2016-12-09')
    end

    it 'calculates the due date when it is written as prompt' do
      # From ZqMX24iDMxxst5cnP.pdf

      DateTerm.create(
        text: '21.09.2016',
        left: 0.3403333333333333,
        right: 0.422,
        top: 0.264075382803298,
        bottom: 0.272791519434629
      )

      DueDateLabelTerm.create(
        text: 'Zahlungsziel:',
        left: 0.0003333333333333333,
        right: 0.09666666666666666,
        top: 0.5762073027090695,
        bottom: 0.5872791519434629
      )

      RelativeDateTerm.create(
        text: 'prompt',
        left: 0.11866666666666667,
        right: 0.16933333333333334,
        top: 0.5769140164899882,
        bottom: 0.5872791519434629
      )

      due_date = DateCalculation.new(
        DateTerm.dataset
      ).due_date

      expect(due_date).to eq DateTime.iso8601('2016-09-21')
    end
  end
end
