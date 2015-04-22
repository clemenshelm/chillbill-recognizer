require 'opencv'

class DocumentUnskewer
  include OpenCV

  CANNY_THRESHOLD = 100

  def initialize(image_path: nil, mat: nil)
    @image_mat = mat || CvMat.load(image_path, CV_LOAD_IMAGE_COLOR)
    @width, @height = @image_mat.size
  end

  def rotation_angle_degrees
    gray = @image_mat.BGR2GRAY
    gray = gray.canny(CANNY_THRESHOLD, CANNY_THRESHOLD * 2)

    lines = gray.hough_lines(:probabilistic, 1, Math::PI / 1800, 100, @width / 15, 20)
    angles = lines.map { |line|
      start_point, end_point = line
      Math.atan2(end_point.y - start_point.y, end_point.x - start_point.x)
    }
    angles -= [0.0] # Clear accidental results
    # Make all angles be around 0 degrees
    ninety = Math::PI / 2
    angles.map! { |angle| (angle + ninety) % ninety }
    angles.map! { |angle| angle > ninety / 2 ? angle - ninety : angle }
    median_angle = angles.sort[angles.size / 2]

    median_angle * 180 / Math::PI # Convert to degrees
  end

  def save_unskewed_image(to:)
    rotation_center = CvPoint2D32f.new(@width / 2.0, @height / 2.0)
    rotation_matrix = CvMat.rotation_matrix2D(rotation_center, rotation_angle_degrees, 1)
    rotated_image = @image_mat.warp_affine(rotation_matrix)
    rotated_image.save_image to
  end
end
