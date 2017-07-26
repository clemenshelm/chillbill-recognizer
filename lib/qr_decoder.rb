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
    prices_present = prices_and_vats.select do |_vat, price|
      /^(?!.*0,00).*$*\d,\d{2}/ =~ price
    end

    date_in_qr = DateTime.strptime(all_data[4], '%Y-%m-%d').strftime('%Y-%m-%d')
    total = (
      BigDecimal.new(prices_present.values.first.sub!(',', '.')) * 100
    ).to_i

    {
      invoiceDate: date_in_qr,
      dueDate: date_in_qr,
      amounts: [{
        total: total,
        vatRate: prices_present.keys.first
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
