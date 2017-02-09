# frozen_string_literal: true
require 'rmagick'

class ImageProcessor
  class InvalidImage < StandardError; end
  include Magick
  attr_reader :image_width
  attr_reader :image_height
  def initialize(image_path)
    begin
      # Only read first page of bill
      original_image = Image.read("#{image_path}[0]")[0]
      unless original_image
        raise InvalidImage, 'Cannot read image. Maybe the PDF has errors?'
      end
      density = calculate_density(original_image.page)
      @image_width = original_image.page.width
      @image_height = original_image.page.height
    ensure
      original_image&.destroy!
    end
    @image = Image.read(image_path) { self.density = density }[0]
  end

  def calculate_density(page)
    min_dimension = [page.width, page.height].min
    # This will give us an image with at least 3000px on each dimension
    220_000.0 / min_dimension
  end

  def calculate_orientation
    orientation = @image.get_exif_by_entry('Orientation')
    case orientation.first.last
    when '1'
      0
    when '6'
      1
    when '3'
      2
    when '8'
      3
    end
  end

  def correct_orientation
    @image.auto_orient!
    @image_width = @image.page.width
    @image_height = @image.page.height
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

  # def image_width
  #   @image.page.width
  # end
  #
  # def image_height
  #   @image.page.height
  # end

  def deskew
    process_image { |image| image.deskew(0.4) }
  end

  def normalize
    process_image(&:normalize)
  end

  def improve_level
    process_image do |image|
      image.level(0.1 * QuantumRange, 0.9 * QuantumRange, 1.5)
    end
  end

  def trim
    @image.fuzz = '80%'
    @image.trim!
    self
  end

  def write_png!
    png_file = Tempfile.new ['bill', '.png']
    @image.write png_file.path
    return png_file
  ensure
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
