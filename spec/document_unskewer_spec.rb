require 'grim'
require_relative '../lib/document_unskewer'
require 'tempfile'

def image_fixture(name, format:)
  pdf_path = File.expand_path("../image_fixtures/#{name}.pdf", __FILE__)
  image_path = File.expand_path("../image_fixtures/cache/#{name}.png", __FILE__) 

  unless File.exist?(image_path)
    pdf = Grim.reap(pdf_path)
    pdf[0].save image_path, width: 3000, quality: 100
  end

  image_path
end

RSpec.describe 'unskewing an image' do
  it 'detects the correct angle for an almost straight document' do
    image_path = image_fixture('baumax1', format: :png)
    unskewer = DocumentUnskewer.new(image_path: image_path)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(1)
  end

  it 'detects the correct angle for an inclined document' do
    image_path = image_fixture('lidl1', format: :png)
    unskewer = DocumentUnskewer.new(image_path: image_path)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(-6)
  end

  it 'detects the correct angle for a 90 degree rotated document' do
    image_path = image_fixture('stadtwien1', format: :png)
    unskewer = DocumentUnskewer.new(image_path: image_path)

    # Actually it should be 90, but it's hard to detect where the text top is.
    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(-90)
  end

  it 'rotates the document so it is straight' do
    image_path = image_fixture('lidl1', format: :png)
    unskewer = DocumentUnskewer.new(image_path: image_path)

    unskewed_path = 'image.png'
    unskewer.save_unskewed_image to: unskewed_path
    
    assertion_unskewer = DocumentUnskewer.new(image_path: unskewed_path)
    expect(assertion_unskewer.rotation_angle_degrees).to be_within(0.1).of(0)
    
    File.unlink(unskewed_path)
  end
end
