require 'tempfile'
require 'grim'

class BillImageRetriever
  def initialize(url:)
    @url = url
  end

  def save_to(path)
    pdf_io = open @url, 'rb'
    pdf_file = Tempfile.new ['bill', '.pdf']
    IO.copy_stream pdf_io, pdf_file

    pdf = Grim.reap(pdf_file.path)
    pdf[0].save path
    pdf_file.close!
  end
end
