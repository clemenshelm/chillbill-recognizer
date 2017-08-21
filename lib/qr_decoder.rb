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

    filtered_data = determine_data_format_and_set_data(all_data)

    date, prices, vat_rates = filtered_data.values_at(:date, :prices, :vat_rates)

    date = DateTime.strptime(date, '%Y-%m-%d').strftime('%Y-%m-%d')

    {
      invoiceDate: date,
      dueDate: date,
      amounts: calculate_amounts(prices, vat_rates)
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

  def determine_data_format_and_set_data(qr_code_parts)
    if qr_code_parts[1] == 'R1'
      {
        vat_rates: [20, 13, 10, 0, nil],
        prices: qr_code_parts[6..10],
        date: qr_code_parts[5]
      }
    else
      {
        vat_rates: [20, 10, 13, 0, nil],
        prices: qr_code_parts[5..9],
        date: qr_code_parts[4]
      }
    end
  end

  def calculate_amounts(prices, vat_rates)
    formatted_prices = prices.map do |p|
      (BigDecimal.new(p.sub(',', '.')) * 100).to_i
    end

    prices_and_vats = vat_rates.zip(formatted_prices).to_h
    prices_present = prices_and_vats.select { |_vat, price| price.positive? }

    prices_present.map do |vat, price|
      {
        total: price,
        vatRate: vat
      }
    end
  end
end
