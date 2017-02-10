# frozen_string_literal: true
require 'rmagick'
require_relative '../lib/image_processor'

describe ImageProcessor do
  include Magick
  # it 'auto corrects the orientation of a bill image' do
  #   file_id = 'gCQ76uE6qLYhEdsY9'
  #   file_url =
  #     "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"
  #
  #   download = BillImageRetriever.new(url: file_url)
  #   image_file = download.save
  #   image = ImageProcessor.new(image_file.path)
  #   original_height = image.image_height
  #   original_width = image.image_width
  #   corrected_bill = image.correct_orientation
  #   corrected_width = corrected_bill.image_width
  #   corrected_height = corrected_bill.image_height
  #
  #   expect(corrected_height).to eq 4032
  #   expect(corrected_width).to eq 3024
  #   expect(corrected_height).to_not eq original_height
  #   expect(corrected_width).to_not eq original_width
  # end
  #

  it 'gets the orientation of a bill image', :focus do
    image = Magick::Image.new(2, 3)
    image['orientation'] = 'Rotate 90 CW'
    image.write('image.jpg')

    image = ImageProcessor.new('image.jpg')
    orientation = image.calculate_clockwise_rotations_required

    expect(orientation).to eq 1
  end

  it "gets the width of a bill's first page" do
    image = Magick::Image.new(2, 3)
    image.write('image.png')

    image = ImageProcessor.new('image.png')
    width = image.image_width

    expect(width).to eq 2
  end

  it "gets the height of a bill's first page" do
    image = Magick::Image.new(2, 3)
    image.write('image.png')

    image = ImageProcessor.new('image.png')
    height = image.image_height

    expect(height).to eq 3
  end

  it "gets the height of a bill's first page after fixing the orientation" do
    # This one is also still broken...
    image = Magick::Image.new(2, 3)
    image['orientation'] = '6'
    image.write('image.jpg')

    image = ImageProcessor.new('image.png').correct_orientation
    height = image.image_height

    expect(height).to eq 3
  end

  # it "gets the width of a bill's first page after fixing the orientation" do
  #   file_id = 'gCQ76uE6qLYhEdsY9'
  #   file_url =
  #     "https://chillbill-prod.s3-eu-central-1.amazonaws.com/#{file_id}.JPG"
  #
  #   download = BillImageRetriever.new(url: file_url)
  #   image_file = download.save
  #   image = ImageProcessor.new(image_file.path).correct_orientation
  #   width = image.image_width
  #
  #   expect(width).to eq 3024
  # end
end
