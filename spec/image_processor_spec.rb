# frozen_string_literal: true
require 'rmagick'
require_relative '../lib/image_processor'

describe ImageProcessor, :focus do
  include Magick

  let(:image) { ImageProcessor.new('./spec/support/orientation-test.jpg') }

  it 'auto corrects the orientation of a bill image' do
    original_height = image.image_height
    original_width = image.image_width
    corrected_bill = image.correct_orientation
    corrected_width = corrected_bill.image_width
    corrected_height = corrected_bill.image_height

    expect(corrected_height).to eq 2
    expect(corrected_width).to eq 3
    expect(corrected_height).to_not eq original_height
    expect(corrected_width).to_not eq original_width
  end

  it 'gets the orientation of a bill image' do
    orientation = image.calculate_clockwise_rotations_required

    expect(orientation).to eq 1
  end

  it "gets the width of a bill's first page" do
    width = image.image_width
    expect(width).to eq 2
  end

  it "gets the height of a bill's first page" do
    height = image.image_height
    expect(height).to eq 3
  end

  it "gets the height of a bill's first page after fixing the orientation" do
    corrected_image = image.correct_orientation
    height = corrected_image.image_height

    expect(height).to eq 2
  end

  it "gets the width of a bill's first page after fixing the orientation" do
    corrected_image = image.correct_orientation
    width = corrected_image.image_width
    expect(width).to eq 3
  end
end
