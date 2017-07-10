# frozen_string_literal: true
require 'zbar'

class QRDecoder
  include Magick

  def initialize(image)
    @image = image
  end

  def qr_code?
    tmp_image = @image.dup
    image_blob = tmp_image.to_blob do
      self.depth = 8
      self.format = 'PGM'
    end
    tmp_image.destroy!

    @zbar_image = ZBar::Image.from_pgm(image_blob).process

    !@zbar_image.empty?
  end

  def decode_qr_code
    return unless qr_code?
    all_data = @zbar_image.last.instance_variable_get(:@data).split('_')
    processed_data = {
      dueDate: all_data[4],
      amounts: {
        total: all_data[5] || all_data[6],
        vatRate: all_data[5] ? 20 : 10
      }
    }
    processed_data
  end
end
