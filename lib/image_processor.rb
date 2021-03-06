# frozen_string_literal: true
require 'rmagick'

class ImageProcessor
  class InvalidImage < StandardError; end
  include Magick
  attr_reader :image_width, :image_height, :image

  def initialize(image_path)
    read_path = "#{image_path}[0]"
    begin
      # Only read first page of bill
      original_image = Image.read(read_path)[0]
      unless original_image
        raise InvalidImage, 'Cannot read image. Maybe the PDF has errors?'
      end
      density = calculate_density(original_image.page)
    ensure
      original_image&.destroy!
    end
    @image = Image.read(read_path) { self.density = density }[0]
    @image_width = @image.columns
    @image_height = @image.rows
    @image
  end

  def calculate_density(page)
    min_dimension = [page.width, page.height].min
    # This will give us an image with at least 3000px on each dimension
    220_000.0 / min_dimension
  end

  def calculate_clockwise_rotations_required
    orientation = @image.get_exif_by_entry('Orientation')
    case orientation.first.last
    when '6' then 1
    when '3' then 2
    when '8' then 3
    else 0
    end
  end

  def correct_orientation
    @image.auto_orient!
    update_width_and_height
    self
  end

  def apply_background(color)
    background = Image.new(@image.columns, @image.rows) do |image|
      image.background_color = color
    end
    process_image do |image|
      background.composite(
        image, Magick::NorthEastGravity, Magick::OverCompositeOp
      )
    end
  ensure
    background&.destroy!
  end

  def deskew
    process_image do |image|
      image.deskew(0.4, @image_width)
    end
    update_width_and_height
    self
  end

  def normalize
    process_image(&:normalize)
  end

  def update_width_and_height
    @image_width = @image.columns
    @image_height = @image.rows
  end

  def improve_level
    process_image do |image|
      image.level(0.1 * QuantumRange, 0.9 * QuantumRange, 1.5)
    end
  end

  def preprocess
    correct_orientation
    apply_background('#fff')
    deskew
    normalize
    improve_level
  end

  def write_png
    png_file = Tempfile.new ['bill', '.png']
    @image.write png_file.path
    png_file
  end

  def destroy!
    @image.destroy!
  end

  private

  def process_image
    original_image = @image
    @image = yield @image
    self
  ensure
    original_image&.destroy!
  end
end
