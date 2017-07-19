# frozen_string_literal: true
require 'zbar'

class QRDecoder
  include Magick
  VAT_RATES = [
    20,
    10,
    13,
    0,
    nil
  ].freeze

  def initialize(image)
    @image = image
  end

  def qr_code?
    !qr_codes.empty?
  end

  def decode_qr_code
    return unless qr_code?
    all_data = qr_codes.last.data.split('_')
    prices = all_data.grep(/\d,\d{2}/)
    prices_and_vats = VAT_RATES.zip(prices).to_h
    compacted_prices_and_vats = prices_and_vats.select do |_vat, price|
      /^(?!.*0,00).*$*\d,\d{2}/ =~ price
    end

    # Processed QR code data:
    {
      invoiceDate: DateTime.strptime(
        all_data[4], '%Y-%m-%d'
      ).strftime('%Y-%m-%d'),
      dueDate: DateTime.strptime(
        all_data[4], '%Y-%m-%d'
      ).strftime('%Y-%m-%d'),
      amounts: [{
        total: (BigDecimal.new(
          compacted_prices_and_vats.values.first.sub!(',', '.')
        ) * 100
               ).to_i,
        vatRate: compacted_prices_and_vats.keys.first
      }]
    }
  end

  private

  def qr_codes
    return @qr_codes if @qr_codes
    tmp_image = @image.dup
    image_blob = tmp_image.to_blob do
      self.depth = 8
      self.format = 'PGM'
    end
    tmp_image.destroy!

    @qr_codes = ZBar::Image.from_pgm(image_blob).process(symbology: :qrcode)
  end
end
