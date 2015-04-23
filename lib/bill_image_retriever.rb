require 'tempfile'
require 'grim'
require 'open-uri'

class BillImageRetriever
  def initialize(url:)
    @url = url
  end

  def save
    pdf_io = open @url, 'rb'
    pdf_file = Tempfile.new ['bill', '.pdf']
    IO.copy_stream pdf_io, pdf_file

    image_file = Tempfile.new ['bill', '.png']
    pdf = Grim.reap(pdf_file.path)
    pdf[0].save(image_file.path, width: 3000, quality: 100)
    pdf_file.close!

    image_file
  end
end
