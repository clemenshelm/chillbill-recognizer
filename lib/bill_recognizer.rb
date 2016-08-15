# encoding: utf-8
require 'bigdecimal'
require 'rmagick'
require 'pry'
require 'nokogiri'
require_relative './boot'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './calculations/date_calculation'
require_relative './calculations/vat_number_calculation'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './detectors/vat_number_detector'
require_relative './models/word'
require_relative './models/price_term'
require_relative './models/date_term'
require_relative './models/vat_number_term'
require_relative './config'
require_relative './logging'

class BillRecognizer
  include Magick
  include Logging

  def initialize(image_url: nil, retriever: nil, customer_vat_number: nil)
    @retriever = retriever || BillImageRetriever.new(url: image_url)
    @customer_vat_number = customer_vat_number
  end

  def recognize
    # Make sure database is empty
    Word.dataset.delete
    PriceTerm.dataset.delete
    DateTerm.dataset.delete
    VatNumberTerm.dataset.delete

    # Download and convert image
    image_file = @retriever.save
    preprocess image_file.path
    # FileUtils.rm('./test.png')
    # FileUtils.cp(image_file.path, './test.png')

    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    hocr = `tesseract "#{image_file.path}" stdout -c tessedit_create_hocr=1 -c tessedit_char_whitelist="#{Config[:tesseract_whitelist]}" -l eng+deu`
      .force_encoding('UTF-8')
    # logger.debug hocr

    hocr_doc = Nokogiri::HTML(hocr)
    hocr_doc.css(".ocrx_word").each do |word_node|
      left, top, right, bottom = word_node[:title]
        .match(/(\d+) (\d+) (\d+) (\d+);/)
        .captures
        .map(&:to_i)

      Word.create(text: word_node.text, left: left, right: right, top: top, bottom: bottom)
    end
    # logger.debug Word.map(&:text)
    logger.debug Word.map { |word| "text: #{word.text}, left: #{word.left}, right: #{word.right}, top: #{word.top}, bottom: #{word.bottom}" }

    price_words = PriceDetector.filter
    # logger.debug price_words.map { |word| "PriceTerm.create(text: '#{word.text}', left: '#{word.left}', right: '#{word.right}', top: '#{word.top}', bottom: '#{word.bottom}')" }
    prices = PriceCalculation.new(price_words)
    net_amount = prices.net_amount
    vat_amount = prices.vat_amount

    date_words = DateDetector.filter
    dates = DateCalculation.new(date_words)
    if dates.invoice_date
      invoice_date = dates.invoice_date.strftime('%Y-%m-%d')
    end

    vat_number_words = VatNumberDetector.filter
    vat_number = VatNumberCalculation.new(
      vat_number_words,
      customer_vat_number: @customer_vat_number
    ).vat_number

    #image_file.close

    return {} if net_amount.nil?

    # Adapt recognition result to application schema
    # TODO: Let price calculation produce required format
    subTotal = net_amount * 100
    vatTotal = vat_amount * 100
    total = (subTotal + vatTotal).to_i
    vatRate =
      if subTotal != 0
        (vatTotal * 100 / subTotal).round
      else
        0
      end

    {
      amounts: [total: total, vatRate: vatRate],
      invoiceDate: invoice_date,
      vatNumber: vat_number
    }
  end

  private

  def preprocess(image_path)
    image = Image.read(image_path)[0]
    background = Image.new(image.columns, image.rows) do |image|
      image.background_color = '#fff'
    end
    image = background.composite(image, Magick::NorthEastGravity, Magick::OverCompositeOp)
    image.fuzz = "99%"
    image = image.deskew(0.4)
    image = image.normalize
    image.level 0.6 * QuantumRange
    image.trim!
    image.write image_path
  end
end
