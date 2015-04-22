require 'tesseract'
require 'bigdecimal'
require_relative './document_unskewer'
require_relative './document_enhancer'
require_relative './bill_image_retriever'

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
    unskewer.save_unskewed_image to: 'rotated.png'
    
    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    tesseract = Tesseract::Engine.new do |e|
      e.language = :deu
    end

    # simple price detection
    words = tesseract.words_for 'rotated.png'
    price_words = words.select { |word| word.text =~ /^\d+[\.,]\d{2}$/ rescue nil }
    price_texts = price_words.map(&:text)

    prices = price_texts.map { |price_text| BigDecimal.new(price_text.sub(',', '.')) }.uniq
    net_amount, vat_amount = net_and_vat_amount(prices)

    image_file.close

    net_amount.nil? ? {} : {subTotal: net_amount.to_s('F'), vatTotal: vat_amount.to_s('F')}
  end

  def net_and_vat_amount(prices)
    prices.each do |total_amount|
      remaining_prices = prices - [total_amount]
      remaining_prices.each do |net_amount|
        possible_vat_amounts = remaining_prices.select { |price| price <= (net_amount * BigDecimal('0.2')).ceil(2) }
        possible_vat_amounts.each do |vat_amount|
          if net_amount + vat_amount == total_amount
            return [net_amount, vat_amount] 
          end
        end
      end
    end

    nil
  end
end
