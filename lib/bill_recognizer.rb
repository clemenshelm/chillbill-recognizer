# encoding: utf-8
require 'bigdecimal'
require 'rmagick'
require 'pry'
require 'nokogiri'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './detectors/price_detector'
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
      x, y, width, height = word_node[:title]
        .match(/(\d+) (\d+) (\d+) (\d+);/)
        .captures
        .map(&:to_i)

      Word.new word_node.text, x: x, y: y, width: width, height: height
    end

    price_words = PriceDetector.filter(words)
    price_texts = price_words.map(&:text)

    prices_decimals = price_texts.map { |price_text| BigDecimal.new(price_text.sub(',', '.')) }.uniq
    prices = PriceCalculation.new(price_words)
    net_amount = prices.net_amount
    vat_amount = prices.vat_amount

    #image_file.close

    net_amount.nil? ? {} : {subTotal: '%.2f' % net_amount, vatTotal: '%.2f' % vat_amount}
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
