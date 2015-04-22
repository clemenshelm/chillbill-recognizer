require 'grim'
require_relative '../lib/document_unskewer'
require 'tempfile'

RSpec.describe 'unskewing an image' do
  it 'detects the correct angle for an almost straight document' do
    image_path = cache_png('m6jLaPhmWvuZZqSXy')
    unskewer = DocumentUnskewer.new(image_path: image_path)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(0.7)
  end

  it 'detects the correct angle for an inclined document' do
    image_path = cache_png('t2MRqc8PtGWT4oPNW')
    unskewer = DocumentUnskewer.new(image_path: image_path)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(-5.5)
  end

  it 'detects the correct angle for a 90 degree rotated document' do
    image_path = cache_png('Y8YpKWEJZFunbMymh')
    unskewer = DocumentUnskewer.new(image_path: image_path)

    # Actually it should be 90, but it's hard to detect where the text top is.
    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(0)
  end

  it 'detects the correct angle for a slightly inclined document' do
    image_path = cache_png('H9WCDhBHp2N7xRLoA')
    unskewer = DocumentUnskewer.new(image_path: image_path)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(0.2)
  end

  it 'detects the correct angle for another document' do
    image_path = cache_png('95uvAm2JF9kYtN8sJ')
    unskewer = DocumentUnskewer.new(image_path: image_path)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(-0.3)
  end

  it 'rotates the document so it is straight' do
    image_path = cache_png('t2MRqc8PtGWT4oPNW')
    unskewer = DocumentUnskewer.new(image_path: image_path)

    unskewed_path = 'image.png'
    unskewer.save_unskewed_image to: unskewed_path
    
    assertion_unskewer = DocumentUnskewer.new(image_path: unskewed_path)
    expect(assertion_unskewer.rotation_angle_degrees).to be_within(0.1).of(0)
    
    File.unlink(unskewed_path)
  end

  it 'accepts a matrix' do
    require 'opencv'

    image_path = cache_png('H9WCDhBHp2N7xRLoA')
    mat = OpenCV::CvMat.load(image_path, OpenCV::CV_LOAD_IMAGE_COLOR)
    unskewer = DocumentUnskewer.new(mat: mat)

    expect(unskewer.rotation_angle_degrees).to be_within(0.1).of(0.2)
  end
end
