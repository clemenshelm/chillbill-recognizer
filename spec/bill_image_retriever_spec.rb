require 'open-uri'
require 'grim'
require_relative '../lib/bill_image_retriever'

describe BillImageRetriever do
  it 'saves a bill as an image' do
    file_id = 'm6jLaPhmWvuZZqSXy'
    pdf_url = "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.pdf"
    pdf_path = cache_file("#{file_id}.pdf") do |path|
      pdf_io = open pdf_url, 'rb'
      IO.copy_stream pdf_io, path
    end

    image_path = cache_file("#{file_id}.png") do |path|
      pdf = Grim.reap(pdf_path)
      pdf[0].save path
    end

    file_name = File.expand_path("../../tmp/#{rand(100)}.png", __FILE__)
    download = BillImageRetriever.new url: pdf_url
    download.save_to file_name

    expect(File.read(image_path, mode: 'rb')[0..100]).to eq File.read(file_name, mode: 'rb')[0..100]
  end
end
