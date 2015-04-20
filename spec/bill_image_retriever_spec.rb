require 'open-uri'
require 'grim'
require_relative '../lib/bill_image_retriever'

describe BillImageRetriever do
  it 'saves a bill as an image' do
    file_id = 'm6jLaPhmWvuZZqSXy'
    image_path = cache_png(file_id)
    pdf_url = "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.pdf"

    file_name = File.expand_path("../../tmp/#{rand(100)}.png", __FILE__)
    download = BillImageRetriever.new url: pdf_url
    download.save_to file_name

    expect(File.read(image_path, mode: 'rb')[0..100]).to eq File.read(file_name, mode: 'rb')[0..100]
  end
end
