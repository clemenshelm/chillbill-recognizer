# frozen_string_literal: true
require 'zbar'

class QRDecoder
  include Magick

  def initialize(image)
    @image = image
  end

  def qr_code?
    !qr_codes.empty?
  end

  def decode_qr_code
    return unless qr_code?
    all_data = qr_codes.last.data.split('_')
    return unless all_data.length == 14

    if all_data[1] == 'R1'
      vat_rates = [20, 13, 10, 0, nil]
      prices = all_data[6..10].map { |p| BigDecimal.new(p.sub(',', '.')) }
      date_in_qr = DateTime.strptime(all_data[5], '%Y-%m-%d').strftime('%Y-%m-%d')
    else
      vat_rates = [20, 10, 13, 0, nil]
      prices = all_data[5..9].map { |p| BigDecimal.new(p.sub(',', '.')) }
      date_in_qr = DateTime.strptime(all_data[4], '%Y-%m-%d').strftime('%Y-%m-%d')
    end

    prices_and_vats = vat_rates.zip(prices).to_h
    prices_present = prices_and_vats.select { |_vat, price| price.positive? }

    calculated_amounts = prices_present.map do |vat, price|
      {
        total: (price * 100).to_i,
        vatRate: vat
      }
    end

    {
      invoiceDate: date_in_qr,
      dueDate: date_in_qr,
      amounts: calculated_amounts
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
