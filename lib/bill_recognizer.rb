# encoding: utf-8
# frozen_string_literal: true
require 'bigdecimal'
require 'pry'
require 'nokogiri'
require_relative './boot'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './calculations/date_calculation'
require_relative './calculations/vat_number_calculation'
require_relative './calculations/iban_calculation'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/vat_number_detector'
require_relative './detectors/iban_detector'
require_relative './calculations/billing_period_calculation'
require_relative './calculations/currency_calculation'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/vat_number_detector'
require_relative './detectors/billing_period_detector'
require_relative './detectors/currency_detector'
require_relative './models/word'
require_relative './models/price_term'
require_relative './models/date_term'
require_relative './models/vat_number_term'
require_relative './models/iban_term'
require_relative './models/billing_period_term'
require_relative './models/currency_term'
require_relative './config'
require_relative './logging'
require_relative './image_processor'

class BillRecognizer
  include Logging

  def initialize(image_url: nil, retriever: nil, customer_vat_number: nil)
    @retriever = retriever || BillImageRetriever.new(url: image_url)
    @customer_vat_number = customer_vat_number
  end

  def recognize
    # Make sure database is empty
    Word.dataset.delete
    PriceTerm.dataset.delete
    BillingPeriodTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete
    IbanTerm.dataset.delete
    CurrencyTerm.dataset.delete

    # Download and convert image
    image_file = @retriever.save
    preprocess image_file.path

    # FileUtils.rm('./test.png')
    # FileUtils.cp(image_file.path, './test.png')

    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    hocr =
      `tesseract "#{image_file.path}" stdout -c tessedit_create_hocr=1 -c
      tessedit_char_whitelist="#{Config[:tesseract_whitelist]}" -l eng+deu`
      .force_encoding('UTF-8')
    # logger.debug hocr

    hocr_doc = Nokogiri::HTML(hocr)
    hocr_doc.css('.ocrx_word').each do |word_node|
      left, top, right, bottom = word_node[:title]
                                 .match(/(\d+) (\d+) (\d+) (\d+);/)
                                 .captures
                                 .map(&:to_i)

      left /= @width.to_f
      right /= @width.to_f
      top /= @height.to_f
      bottom /= @height.to_f

      Word.create(
        text: word_node.text,
        left: left,
        right: right,
        top: top,
        bottom: bottom
      )
    end

    # logger.debug Word.map(&:text)

    # logger.debug Word.map {
    #  |word| "text: #{word.text},
    #  left: #{word.left},
    #  right: #{word.right},
    #  top: #{word.top},
    #  bottom: #{word.bottom}"
    # }

    # puts Word.map { |word|
    #        "
    #        text: \'#{word.text}\',
    #        left: #{word.left},
    #        right: #{word.right},
    #        top: #{word.top},
    #        bottom: #{word.bottom}
    #        "
    #      }

    price_words = PriceDetector.filter
    logger.debug price_words.map { |word|
      "PriceTerm.create(
        text: '#{word.text}',
        left: '#{word.left}',
        right: '#{word.right}',
        top: '#{word.top}',
        bottom: '#{word.bottom}'
      )"
    }
    date_words = DateDetector.filter
    vat_number_words = VatNumberDetector.filter
    billing_period_words = BillingPeriodDetector.filter
    currency_words = CurrencyDetector.filter
    iban_words = IbanDetector.filter

    calculated_billing_period = BillingPeriodCalculation.new(
      billing_period_words
    ).billing_period

    billing_period = calculated_billing_period.update(
      calculated_billing_period
    ) { |_key, value| value.strftime('%Y-%m-%d') } if calculated_billing_period

    dates = DateCalculation.new(date_words)
    invoice_date = dates.invoice_date.strftime('%Y-%m-%d') if dates.invoice_date

    prices = PriceCalculation.new(price_words)
    net_amount = prices.net_amount
    vat_amount = prices.vat_amount

    vat_number = VatNumberCalculation.new(
      vat_number_words,
      customer_vat_number: @customer_vat_number
    ).vat_number

    iban = IbanCalculation.new(iban_words).iban

    currency = CurrencyCalculation.new(currency_words).iso

    due_datetime = DateCalculation.new(date_words).due_date
    due_date = due_datetime.strftime('%Y-%m-%d') if due_datetime

    # image_file.close
    return {} if net_amount.nil?

    # Adapt recognition result to application schema
    # TODO: Let price calculation produce required format
    sub_total = net_amount * 100
    vat_total = vat_amount * 100
    total = (sub_total + vat_total).to_i
    vat_rate =
      if sub_total.nonzero?
        (vat_total * 100 / sub_total).round
      else
        0
      end

    {
      amounts: [total: total, vatRate: vat_rate],
      invoiceDate: invoice_date,
      vatNumber: vat_number,
      billingPeriod: billing_period,
      currencyCode: currency,
      dueDate: due_date,
      iban: iban
    }
  end

  private

  def preprocess(image_path)
    image = ImageProcessor.new(image_path)

    @width = image.image_width
    @height = image.image_height

    image.apply_background('#fff')
         .deskew
         .normalize
         .trim
         .write!(image_path)
  end
end
