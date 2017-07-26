# frozen_string_literal: true
require 'bigdecimal'
require 'pry'
require 'nokogiri'
require 'yaml'
require_relative './boot'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './calculations/date_calculation'
require_relative './calculations/vat_number_calculation'
require_relative './calculations/iban_calculation'
require_relative './calculations/billing_period_calculation'
require_relative './calculations/currency_calculation'
require_relative './calculations/invoice_number_calculation'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/vat_number_detector'
require_relative './detectors/iban_detector'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/billing_period_detector'
require_relative './detectors/currency_detector'
require_relative './detectors/due_date_label_detector'
require_relative './detectors/relative_date_detector'
require_relative './detectors/invoice_date_label_detector'
require_relative './detectors/billing_start_label_detector'
require_relative './detectors/billing_end_label_detector'
require_relative './detectors/invoice_number_detector'
require_relative './detectors/invoice_number_label_detector'
require_relative './models/word'
require_relative './models/price_term'
require_relative './models/date_term'
require_relative './models/vat_number_term'
require_relative './models/iban_term'
require_relative './models/billing_period_term'
require_relative './models/currency_term'
require_relative './models/due_date_label_term'
require_relative './models/billing_start_label_term'
require_relative './models/billing_end_label_term'
require_relative './models/invoice_number_label_term'
require_relative './models/invoice_number_term'
require_relative './models/bill_dimension'
require_relative './config'
require_relative './logging'
require_relative './image_processor'
require_relative './qr_decoder'

class BillRecognizer
  include Logging

  TABLES = [
    Word,
    PriceTerm,
    BillingPeriodTerm,
    DateTerm,
    VatNumberTerm,
    IbanTerm,
    CurrencyTerm,
    DueDateLabelTerm,
    InvoiceDateLabelTerm,
    BillingStartLabelTerm,
    BillingEndLabelTerm,
    RelativeDateTerm,
    InvoiceDateLabelTerm,
    InvoiceNumberTerm,
    BillDimension
  ].freeze

  DETECTORS = [
    PriceDetector,
    DateDetector,
    VatNumberDetector,
    BillingPeriodDetector,
    CurrencyDetector,
    IbanDetector,
    DueDateLabelDetector,
    RelativeDateDetector,
    InvoiceDateLabelDetector,
    BillingStartLabelDetector,
    BillingEndLabelDetector,
    InvoiceNumberLabelDetector,
    InvoiceNumberDetector
  ].freeze

  def initialize(image_url: nil, retriever: nil, customer_vat_number: nil)
    @retriever = retriever || BillImageRetriever.new(url: image_url)
    @customer_vat_number = customer_vat_number
  end

  def recognize
    empty_database
    version = fetch_recognizer_version

    begin
      png_file = download_and_convert_image
    rescue UnprocessableFileError, ImageProcessor::InvalidImage => e
      return { error: e.to_s, recognizerVersion: version }
    end

    recognize_words(png_file)
    calculate_text_box

    filter_words
    calculate_attributes(version)
  ensure
    @image&.destroy!
  end

  def download_and_convert_image
    image_file = @retriever.save
    @image = ImageProcessor.new(image_file.path)
    png_file = @image.preprocess.write_png

    BillDimension.create_all(width: @image.image_width, height: @image.image_height)

    png_file
  end

  def empty_database
    TABLES.each { |table| table.dataset.delete }
  end

  def fetch_recognizer_version
    version_data = YAML.load_file 'lib/version.yml'
    version_data['Version']
  end

  def recognize_words(png_file)
    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    hocr = perform_ocr(png_file)

    hocr_doc = Nokogiri::HTML(hocr)
    create_words_from_hocr(hocr_doc)

    # puts Word.map { |word|
    #   "
    #   text: \'#{word.text}\',
    #   left: #{word.left},
    #   right: #{word.right},
    #   top: #{word.top},
    #   bottom: #{word.bottom}
    #   "
    # }
  end

  def perform_ocr(png_file)
    tesseract_config = configure_tessarect
    `tesseract "#{png_file.path}" stdout -l eng+deu #{tesseract_config}`
      .force_encoding('UTF-8')
  end

  def configure_tessarect
    {
      tessedit_create_hocr: 1,
      tessedit_char_whitelist: %("#{Config[:tesseract_whitelist]}")
    }.map { |k, v| "-c #{k}=#{v}" }.join(' ')
  end

  def create_words_from_hocr(hocr_doc)
    hocr_doc.css('.ocrx_word').each do |word_node|
      left, top, right, bottom = word_node[:title]
                                 .match(/(\d+) (\d+) (\d+) (\d+);/)
                                 .captures
                                 .map(&:to_i)
      adjusted_word = adjust_word_attributes(left, top, right, bottom)
      create_word(word_node, adjusted_word)
    end
  end

  def adjust_word_attributes(left, top, right, bottom)
    width = @image.image_width
    height = @image.image_height

    {
      left: left / width.to_f,
      right: right / width.to_f,
      top: top / height.to_f,
      bottom: bottom / height.to_f
    }
  end

  def create_word(word_node, adjusted_word)
    Word.create(
      text: word_node.text,
      left: adjusted_word[:left],
      right: adjusted_word[:right],
      top: adjusted_word[:top],
      bottom: adjusted_word[:bottom]
    )
  end

  def calculate_text_box
    text_box_top = Word.select_order_map(:top).first
    text_box_bottom = Word.select_order_map(:bottom).last
    text_box_left = Word.select_order_map(:left).first
    text_box_right = Word.select_order_map(:right).last

    BillDimension.text_box_boundaries(
      text_box_top: text_box_top,
      text_box_bottom: text_box_bottom,
      text_box_left: text_box_left,
      text_box_right: text_box_right
    )
  end

  def filter_words
    DETECTORS.each(&:filter)
  end

  def calculate_attributes(version)
    {
      amounts: calculate_amounts,
      invoiceDate: calculate_invoice_date,
      vatNumber: calculate_vat_number,
      billingPeriod: calculate_billing_period,
      currencyCode: calculate_currency,
      dueDate: calculate_due_date,
      iban: calculate_iban,
      invoiceNumber: calculate_invoice_number,
      clockwiseRotationsRequired: @image.calculate_clockwise_rotations_required,
      qrCodePresent: QRDecoder.new(@image.image).qr_code?,
      recognizerVersion: version
    }
  end

  def calculate_amounts
    amounts = []
    prices = PriceCalculation.new
    return amounts if prices.net_amount.nil?
    amounts << {
      total: (prices.net_amount + prices.vat_amount).to_i,
      vatRate: calculate_vat_rate(prices)
    }
  end

  def calculate_vat_rate(prices)
    if prices.net_amount.nonzero?
      (prices.vat_amount * 100 / prices.net_amount).round
    else
      0
    end
  end

  def calculate_invoice_date
    DateCalculation.new.invoice_date&.strftime('%Y-%m-%d')
  end

  def calculate_vat_number
    VatNumberCalculation.new(
      customer_vat_number: @customer_vat_number
    ).vat_number
  end

  def calculate_billing_period
    calculated_billing_period = BillingPeriodCalculation.new.billing_period

    calculated_billing_period&.update(
        calculated_billing_period
      ) { |_key, value| value.strftime('%Y-%m-%d') }
  end

  def calculate_currency
    CurrencyCalculation.new.iso
  end

  def calculate_due_date
    DateCalculation.new.due_date&.strftime('%Y-%m-%d')
  end

  def calculate_iban
    IbanCalculation.new.iban
  end

  def calculate_invoice_number
    InvoiceNumberCalculation.new.invoice_number
  end
end
