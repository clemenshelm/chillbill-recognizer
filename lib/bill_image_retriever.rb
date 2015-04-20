require 'tempfile'
require 'grim'
require 'open-uri'

class BillImageRetriever
  def initialize(url:)
    @url = url
  end

  def save_to(path)
    pdf_io = open @url, 'rb'
    pdf_file = Tempfile.new ['bill', '.pdf']
    IO.copy_stream pdf_io, pdf_file

    pdf = Grim.reap(pdf_file.path)
    pdf[0].save(path, width: 3000, quality: 100)
    pdf_file.close!
  end
end
