require 'open-uri'
require 'tempfile'
require 'tesseract'
require 'grim'
require 'bigdecimal'
require 'pry'
require_relative './document_unskewer'

class BillRecognizer
  include OpenCV

  def initialize(image_url)
    @image_url = image_url
  end

  def recognize
    pdf_file = Tempfile.open 'pdf' do |pdf_file|
      open @image_url, 'rb' do |image_download|
        pdf_file.write(image_download.read)
      end
      pdf_file
    end    

    ENV['TESSDATA_PREFIX'] = '.' # must be specified
    tesseract = Tesseract::Engine.new do |e|
      e.language = :deu
    end
    
    image_file = Tempfile.new ['image', '.png']
    pdf = Grim.reap(pdf_file.path)
    pdf[0].save image_file.path, width: 3000, quality: 100

    # unskew image
    unskewer = DocumentUnskewer.new(image_path: image_file.path)
    unskewer.save_unskewed_image to: 'rotated.png'
    
    # simple price detection
    words = tesseract.words_for 'rotated.png'
    price_words = words.select { |word| word.text =~ /\d+,\d{2}/ rescue nil }
    prices = price_words.map { |price_word| BigDecimal.new(price_word.text.sub(',', '.')) }.uniq
    sorted_prices = prices.sort
    total_amount = sorted_prices.last
    remaining_prices = (prices - [total_amount])
    net_amount, vat_amount = remaining_prices.map { |net_amount| 
      possible_vat_amounts = remaining_prices.select { |price| price < net_amount }
      vat_amount = possible_vat_amounts.find { |vat_amount|
        net_amount + vat_amount == total_amount
      }
      vat_amount ? [net_amount, vat_amount] : nil
    }.compact.first
    
    image_file.close!

    {subTotal: net_amount, vatTotal: vat_amount}
  end
end
