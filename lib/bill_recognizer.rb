require 'open-uri'
require 'tempfile'
require 'tesseract'
require 'grim'
require_relative './document_unskewer'

class BillRecognizer
  include OpenCV

  def initialize(image_url)
    @image_url = image_url
  end

  def recognize
    # pdf_file = Tempfile.open 'pdf' do |pdf_file|
    #   open @image_url, 'rb' do |image_download|
    #     pdf_file.write(image_download.read)
    #   end
    #   pdf_file
    # end    
    # pdf_file_path = pdf_file.path

    tesseract = Tesseract::Engine.new do |e|
      e.language = :eng
    end
    
    #image_file = Tempfile.new ['image', '.png']
    pdf_file_path = 'spec/image_fixtures/stadtwien1.pdf'
    image_file_path = 'image.png'
    pdf = Grim.reap(pdf_file_path)
    pdf[0].save image_file_path, width: 3000, quality: 100

    # unskew image
    unskewer = DocumentUnskewer.new(image_path: image_file_path)
    unskewer.save_unskewed_image to: 'rotated.png'

    puts tesseract.text_for 'rotated.png'
    #image_file.close!

    {}
  end
end
