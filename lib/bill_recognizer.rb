# encoding: utf-8
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
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/vat_number_detector'
require_relative './detectors/iban_detector'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/vat_number_detector'
require_relative './detectors/billing_period_detector'
require_relative './detectors/currency_detector'
require_relative './detectors/due_date_label_detector'
require_relative './detectors/relative_date_detector'
require_relative './detectors/invoice_date_label_detector'
require_relative './detectors/billing_start_label_detector'
require_relative './detectors/billing_end_label_detector'
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
    empty_database
    version = fetch_recognizer_version
    png_file = download_and_convert_image(version)

    # Checks if an error was returned
    return png_file if png_file.is_a?(Hash)

    # FileUtils.rm('./test.png')
    # FileUtils.cp(image_file.path, './test.png')
    hocr(png_file)
    filtered_words = filter_attribute_words
    log_price_words(filtered_words[:price_words])
    filter_labels

    calculate_attributes(filtered_words, version)
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
         .improve_level
         .write_png!
  end

  def empty_database
    Word.dataset.delete
    empty_bill_attribute_datasets
    empty_label_datasets
  end

  def empty_bill_attribute_datasets
    PriceTerm.dataset.delete
    BillingPeriodTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete
    IbanTerm.dataset.delete
    CurrencyTerm.dataset.delete
  end

  def empty_label_datasets
    DueDateLabelTerm.dataset.delete
    InvoiceDateLabelTerm.dataset.delete
    BillingStartLabelTerm.dataset.delete
    BillingEndLabelTerm.dataset.delete
    RelativeDateTerm.dataset.delete
  end

  def fetch_recognizer_version
    version_data = YAML.load_file 'lib/version.yml'
    version_data['Version']
  end

  def download_and_convert_image(version)
    image_file = @retriever.save
    preprocess(image_file.path)
  rescue UnprocessableFileError, ImageProcessor::InvalidImage => e
    return {
      error: e.to_s,
      recognizerVersion: version
    }
  end

  def filter_attribute_words
    {
      price_words: PriceDetector.filter,
      date_words: DateDetector.filter,
      vat_number_words: VatNumberDetector.filter,
      billing_period_words: BillingPeriodDetector.filter,
      currency_words: CurrencyDetector.filter,
      iban_words: IbanDetector.filter
    }
  end

  def log_price_words(price_words)
    logger.debug price_words.map { |word|
      "PriceTerm.create(
        text: '#{word.text}',
        left: '#{word.left}',
        right: '#{word.right}',
        top: '#{word.top}',
        bottom: '#{word.bottom}'
      )"
    }
  end

  def filter_labels
    DueDateLabelDetector.filter
    RelativeDateDetector.filter
    InvoiceDateLabelDetector.filter
    BillingStartLabelDetector.filter
    BillingEndLabelDetector.filter
  end

  def calculate_attributes(filtered_words, version)
    {
      amounts: calculate_amounts(calculate_prices(filtered_words)),
      invoiceDate: calculate_invoice_date(filtered_words),
      vatNumber: calculate_vat_number(filtered_words),
      billingPeriod: calculate_billing_period(filtered_words),
      currencyCode: calculate_currency(filtered_words),
      dueDate: calculate_due_date(filtered_words),
      iban: calculate_iban(filtered_words),
      recognizerVersion: version
    }
  end

  def calculate_amounts(calculated_prices)
    amounts = []
    return amounts if calculated_prices[:net_amount].nil?
    totals = calculate_totals(calculated_prices)
    amounts << {
      total: (totals[:sub_total] + totals[:vat_total]).to_i,
      vatRate: calculate_vat_rate(totals)
    }
  end

  def calculate_invoice_date(filtered_words)
    dates = DateCalculation.new(filtered_words[:date_words])
    dates.invoice_date&.strftime('%Y-%m-%d')
  end

  def calculate_due_date(filtered_words)
    due_datetime = DateCalculation.new(filtered_words[:date_words]).due_date
    due_datetime&.strftime('%Y-%m-%d')
  end

  def calculate_prices(filtered_words)
    prices = PriceCalculation.new(filtered_words[:price_words])
    {
      net_amount: prices.net_amount,
      vat_amount: prices.vat_amount
    }
  end

  def calculate_billing_period(filtered_words)
    calculated_billing_period = BillingPeriodCalculation.new(
      filtered_words[:billing_period_words]
    ).billing_period

    calculated_billing_period&.update(
        calculated_billing_period
      ) { |_key, value| value.strftime('%Y-%m-%d') }
  end

  def calculate_vat_number(filtered_words)
    VatNumberCalculation.new(
      filtered_words[:vat_number_words],
      customer_vat_number: @customer_vat_number
    ).vat_number
  end

  def calculate_totals(calculated_prices)
    # Adapt recognition result to application schema
    # TODO: Let price calculation produce required format
    {
      sub_total: calculated_prices[:net_amount] * 100,
      vat_total: calculated_prices[:vat_amount] * 100
    }
  end

  def calculate_vat_rate(totals)
    if totals[:sub_total].nonzero?
      (totals[:vat_total] * 100 / totals[:sub_total]).round
    else
      0
    end
  end

  def calculate_currency(filtered_words)
    CurrencyCalculation.new(filtered_words[:currency_words]).iso
  end

  def calculate_iban(filtered_words)
    IbanCalculation.new(filtered_words[:iban_words]).iban
  end

  def hocr(png_file)
    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    hocr = configure_hocr(png_file)

    hocr_doc = Nokogiri::HTML(hocr)
    extract_hocr_words(hocr_doc)
    # logger.debug Word.map {
    #  |word| "text: #{word.text},
    #  left: #{word.left},
    #  right: #{word.right},
    #  top: #{word.top},
    #  bottom: #{word.bottom}"
    # }

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

  def configure_tessarect
    {
      tessedit_create_hocr: 1,
      tessedit_char_whitelist: %("#{Config[:tesseract_whitelist]}")
    }.map { |k, v| "-c #{k}=#{v}" }.join(' ')
  end

  def configure_hocr(png_file)
    tesseract_config = configure_tessarect
    `tesseract "#{png_file.path}" stdout -l eng+deu #{tesseract_config}`
      .force_encoding('UTF-8')
    # logger.debug hocr
  end

  def create_word(word_node, left, right, top, bottom)
    Word.create(
      text: word_node.text,
      left: left,
      right: right,
      top: top,
      bottom: bottom
    )
  end

  def extract_hocr_words
    hocr_doc.css('.ocrx_word').each do |word_node|
      left, top, right, bottom = word_node[:title]
                                 .match(/(\d+) (\d+) (\d+) (\d+);/)
                                 .captures
                                 .map(&:to_i)

      left /= @width.to_f
      right /= @width.to_f
      top /= @height.to_f
      bottom /= @height.to_f

      create_word(word_node, left, right, top, bottom)
    end
  end
end
