require 'open-uri'
require 'grim'
require_relative '../lib/bill_image_retriever'

describe BillImageRetriever do
  it 'saves a pdf bill as an image' do
    file_id = 'm6jLaPhmWvuZZqSXy'
    file_url= "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.pdf"
    file_basename = File.basename file_url
    image_path = cache_image(file_basename)

    download = BillImageRetriever.new url: file_url
    file = download.save

    expect(File.read(image_path, mode: 'rb')[0..50]).to eq File.read(file.path, mode: 'rb')[0..50]
  end

  it 'saves a png bill as an image' do
    file_id = '2bQxSCp4nprMZpiSf'
    file_url = "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.png"
    file_basename = File.basename file_url
    image_path = cache_image(file_basename)

    download = BillImageRetriever.new url: file_url
    file = download.save

    expect(File.read(image_path, mode: 'rb')[0..50]).to eq File.read(file.path, mode: 'rb')[0..50]
  end

  it 'saves a jpeg bill as an image' do
    file_id = 'Cetmde5evr2gvwCK4'
    file_url = "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.jpeg"
    file_basename = File.basename file_url
    image_path = cache_image(file_basename)

    download = BillImageRetriever.new url: file_url
    file = download.save

    expect(File.read(image_path, mode: 'rb')[0..50]).to eq File.read(file.path, mode: 'rb')[0..50]
  end

  it 'saves a jpg billas an image' do
    file_id = '47SBGiQfJ4FhXoco7'
    file_url = "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.jpg"
    file_basename = File.basename file_url
    image_path = cache_image(file_basename)

    download = BillImageRetriever.new url: file_url
    file = download.save

    expect(File.read(image_path, mode: 'rb')[0..50]).to eq File.read(file.path, mode: 'rb')[0..50]
  end

  it 'saves a JPG bill as an image' do
    file_id = 'nHX9eYu9pwiFCjSoL'
    file_url = "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"
    file_basename = File.basename file_url
    image_path = cache_image(file_basename)

    download = BillImageRetriever.new url: file_url
    file = download.save

    expect(File.read(image_path, mode: 'rb')[0..50]).to eq File.read(file.path, mode: 'rb')[0..50]
  end

end
