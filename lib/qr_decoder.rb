# frozen_string_literal: true
require 'zbar'

class QRDecoder
  include Magick

  def initialize(image)
    @image = image
  end

  def qr_code?
    return false unless symbol?
    symbology == 'QR-Code'
  end

  private

  def symbol?
    tmp_image = @image.dup
    image_blob = tmp_image.to_blob do
      self.depth = 8
      self.format = 'PGM'
    end
    tmp_image.destroy!

    @zbar_image = ZBar::Image.from_pgm(image_blob).process
    !@zbar_image.empty?
  end

  def symbology
    @zbar_image.last.instance_variable_get(:@symbology)
  end
end
