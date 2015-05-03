require 'tesseract'
require 'bigdecimal'
require 'RMagick'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './detectors/price_detector'

class BillRecognizer
  include Magick

  def initialize(image_url: nil, retriever: nil)
    @retriever = retriever || BillImageRetriever.new(url: image_url)
  end

  def recognize
    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    tesseract = Tesseract::Engine.new do |e|
      e.language = :deu
    end

    # simple price detection
    words = tesseract.words_for image
    price_words = PriceDetector.filter(words)
    price_texts = price_words.map(&:text)

    prices_decimals = price_texts.map { |price_text| BigDecimal.new(price_text.sub(',', '.')) }.uniq
    prices = PriceCalculation.new(price_words)
    net_amount = prices.net_amount
    vat_amount = prices.vat_amount

    #image_file.close

    net_amount.nil? ? {} : {subTotal: '%.2f' % net_amount, vatTotal: '%.2f' % vat_amount}
  end

  def image
    # Download and convert image
    image_file = @retriever.save

    image = ImageList.new image_file.path
    image = image.deskew(0.4)
    image = image.normalize
    image.fuzz = "99%"
    image = image.trim
    image.level 0.6 * QuantumRange
  end
end
