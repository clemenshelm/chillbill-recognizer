require 'rmagick'

class ImageProcessor
  include Magick

  def initialize(image_path)
    @image = Image.read(image_path)[0]
  end

  def apply_background(color)
    background = Image.new(@image.columns, @image.rows) do |image|
      image.background_color = color
    end
    process_image do |image|
      background.composite(image, Magick::NorthEastGravity, Magick::OverCompositeOp)
    end
  ensure
    background && background.destroy!
  end

  def deskew
    process_image { |image| image.deskew(0.4) }
  end

  def normalize
    process_image(&:normalize)
  end

  def improve_level
    process_image { |image| image.level(0.1 * QuantumRange, 0.9 * QuantumRange, 1.5) }
  end

  def trim
    @image.fuzz = '99%'
    @image.trim!
    self
  end

  def write!(image_path)
    @image.write image_path
  ensure
    @image.destroy!
  end

  private

  def process_image
    original_image = @image
    @image = yield @image
    self
  ensure
    original_image && original_image.destroy!
  end
end
