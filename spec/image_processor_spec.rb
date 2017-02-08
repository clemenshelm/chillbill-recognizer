# frozen_string_literal: true
require 'open-uri'
require_relative '../lib/bill_image_retriever'
require_relative '../lib/image_processor'

describe ImageProcessor do
  it 'auto corrects the orientation of a bill image' do
    file_id = 'gCQ76uE6qLYhEdsY9'
    file_url =
      "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"

    download = BillImageRetriever.new(url: file_url)
    image_file = download.save
    image = ImageProcessor.new(image_file.path)
    original_height = image.image_height
    original_width = image.image_width
    corrected_bill = image.correct_orientation
    corrected_width = corrected_bill.image_width
    corrected_height = corrected_bill.image_height

    expect(corrected_height).to eq 4032
    expect(corrected_width).to eq 3024
    expect(corrected_height).to_not eq original_height
    expect(corrected_width).to_not eq original_width
  end

  it 'gets the orientation of a bill image' do
    file_id = 'gCQ76uE6qLYhEdsY9'
    file_url =
      "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"

    download = BillImageRetriever.new(url: file_url)
    image_file = download.save
    image = ImageProcessor.new(image_file.path)
    orientation = image.calculate_orientation

    expect(orientation).to eq 1
  end

  it "gets the height of a bill's first page" do
    file_id = 'gCQ76uE6qLYhEdsY9'
    file_url =
      "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"

    download = BillImageRetriever.new(url: file_url)
    image_file = download.save
    image = ImageProcessor.new(image_file.path)
    height = image.image_height

    expect(height).to eq 3024
  end

  it "gets the width of a bill's first page" do
    file_id = 'gCQ76uE6qLYhEdsY9'
    file_url =
      "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"

    download = BillImageRetriever.new(url: file_url)
    image_file = download.save
    image = ImageProcessor.new(image_file.path)
    width = image.image_width

    expect(width).to eq 4032
  end
end
