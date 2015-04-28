require 'opencv'
require 'tempfile'
require 'pry'
require_relative '../lib/document_enhancer'

RSpec.describe 'enhancing a document' do
  it 'applies a threshold to remove noise pixels' do
    matrix_data = 9.times.map { rand(256) }
    mat = OpenCV::CvMat.new(3, 3, OpenCV::CV_8U, 1)
    mat.set_data matrix_data
    file = Tempfile.new ['threshold', '.png']
    mat.save_image file.path

    enhancer = DocumentEnhancer.new image_path: file.path
    result = enhancer.result
    
    thresholded_data = matrix_data.map { |scalar| scalar < 128 ? 0 : 255 }
    # TODO: Contribute .to_a method to CvMat
    thresholded_data.each_with_index do |scalar, index|
      expect(result[index][0].to_i).to eq scalar
    end

    file.close!
  end
end
