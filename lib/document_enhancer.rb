require 'opencv'

class DocumentEnhancer
  include OpenCV

  def initialize(image_path:)
    @image_mat = CvMat.load(image_path, CV_LOAD_IMAGE_COLOR)
  end

  def result
    @image_mat.threshold 128, 255, CV_THRESH_BINARY
  end
end
