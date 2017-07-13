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

    @qr_codes = ZBar::Image.from_pgm(image_blob).process(symbology: :qrcode)
    !@qr_codes.empty?
  end

  def decode_qr_code
    return unless qr_code?
    all_data = @qr_codes.last.instance_variable_get(:@data).split('_')
    price = all_data.find { |prices| /^(?!.*0,00).*$*\d,\d{2}/ =~ prices }
    processed_data = {
      invoiceDate: DateTime.strptime(all_data[4], '%Y-%m-%d'),
      dueDate: DateTime.strptime(all_data[4], '%Y-%m-%d'),
      amounts: [{
        total: (BigDecimal.new(price.sub!(',', '.')) * 100).to_i,
        vatRate: vat_rate(all_data, price)
      }]
    }

    processed_data
  end

  def vat_rate(all_data, price)
    index = all_data.index(price)
    case index
    when 8
      0
    when 6
      10
    when 5
      20
    end
  end
end
