# encoding: utf-8
require 'bigdecimal'
require 'rmagick'
require 'pry'
require 'nokogiri'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './calculations/date_calculation'
require_relative './detectors/price_detector'
require_relative './detectors/date_detector'
require_relative './word'
require_relative './config'

class BillRecognizer
  include Magick

  def initialize(image_url: nil, retriever: nil)
    @retriever = retriever || BillImageRetriever.new(url: image_url)
  end

  def recognize
    # Download and convert image
    image_file = @retriever.save
    preprocess image_file.path

    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    hocr = `tesseract "#{image_file.path}" stdout -c tessedit_create_hocr=1 -c tessedit_char_whitelist="#{Config[:tesseract_whitelist]}" -l deu`
      .force_encoding('UTF-8')

    hocr_doc = Nokogiri::HTML(hocr)
    words = hocr_doc.css(".ocrx_word").map do |word_node|
      x_left, y_top, x_right, y_bottom = word_node[:title]
        .match(/(\d+) (\d+) (\d+) (\d+);/)
        .captures
        .map(&:to_i)

      Word.new word_node.text, x: x_left, y: y_top, width: (x_right - x_left), height: (y_bottom - y_top)
    end
    # puts words.map { |word| "#{word.text}, x: #{word.bounding_box.x}, y: #{word.bounding_box.y}, width: #{word.bounding_box.width}, height: #{word.bounding_box.height}"}

    price_words = PriceDetector.filter(words)
    prices = PriceCalculation.new(price_words)
    net_amount = prices.net_amount
    vat_amount = prices.vat_amount

    date_words = DateDetector.filter(words)
    dates = DateCalculation.new(date_words)
    if dates.invoice_date
      invoice_date = dates.invoice_date.strftime('%Y-%m-%d')
    end

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
      invoiceDate: invoice_date
    }
  end

  private

  def preprocess(image_path)
    image = ImageList.new image_path
    image = image.deskew(0.4)
    image = image.normalize
    image.fuzz = "99%"
    image = image.trim
    image.level 0.6 * QuantumRange
    image.write image_path
  end
end
