require 'tesseract'
require 'bigdecimal'
require_relative './document_unskewer'
require_relative './document_enhancer'
require_relative './bill_image_retriever'
require_relative './calculations/price_calculation'
require_relative './detectors/price_detector'

class BillRecognizer
  include OpenCV

  def initialize(image_url: nil, retriever: nil)
    @retriever = retriever || BillImageRetriever.new(url: image_url)
  end

  def recognize
    # Download and convert image
    image_file = @retriever.save

    # remove jpg artifacts and unskew image
    enhancer = DocumentEnhancer.new(image_path: image_file.path)
    unskewer = DocumentUnskewer.new(mat: enhancer.result)
    unskewer.save_unskewed_image to: image_file.path
    
    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    tesseract = Tesseract::Engine.new do |e|
      e.language = :deu
    end

    # simple price detection
    words = tesseract.words_for image_file.path
    price_words = PriceDetector.filter(words)
    price_texts = price_words.map(&:text)

    prices_decimals = price_texts.map { |price_text| BigDecimal.new(price_text.sub(',', '.')) }.uniq
    prices = PriceCalculation.new(price_words)
    net_amount = prices.net_amount
    vat_amount = prices.vat_amount

    image_file.close

    net_amount.nil? ? {} : {subTotal: '%.2f' % net_amount, vatTotal: '%.2f' % vat_amount}
  end
end
