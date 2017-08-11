# frozen_string_literal: true
require_relative '../lib/qr_decoder'

describe QRDecoder do
  describe '#qr_code?' do
    it 'detects that an image contains a QR code' do
      image = Magick::Image.read(
        './spec/support/qr-test.pdf'
      ) { self.density = 600 }.first

      decoder = QRDecoder.new(image)
      expect(decoder.qr_code?).to be true
    end

    it 'detects that an image contains no QR code' do
      image = Magick::Image.read(
        './spec/support/no-qr-test.pdf'
      ) { self.density = 600 }.first

      decoder = QRDecoder.new(image)
      expect(decoder.qr_code?).to be false
    end

    it 'does not manipulate the original image' do
      image = Magick::Image.read(
        './spec/support/qr-test.pdf'
      ) { self.density = 600 }.first
      original_image = image.dup

      decoder = QRDecoder.new(image)
      decoder.qr_code?

      expect(image).to eq original_image
    end

    it 'does not process a non QR code symbol' do
      image = Magick::Image.read(
        './spec/support/barcode-test.pdf'
      ) { self.density = 600 }.first

      decoder = QRDecoder.new(image)
      expect(decoder.qr_code?).to be false
    end
  end

  describe '#decode_qr_code' do
    it 'extracts the desired data from a QR code' do
      image = Magick::Image.read(
        './spec/support/qr-test.pdf'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code

      expect(decoded_qr_code).to(include :dueDate) && :amounts
    end

    it 'extracts the date from a QR code' do
      # From jEXku8e2rzutbmxeJ.pdf
      image = Magick::Image.read(
        './spec/support/qr-test.pdf'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code

      expect(decoded_qr_code[:dueDate]).to eq '2017-06-08'
      expect(decoded_qr_code[:invoiceDate]).to eq '2017-06-08'
    end

    it 'extracts the total and vat rate from a QR code' do
      image = Magick::Image.read(
        './spec/support/qr-test.pdf'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code

      expect(decoded_qr_code[:amounts]).to eq [{ total: 6_90, vatRate: 0 }]
    end

    it 'extracts a 0% vat rate price from QR code data' do
      image = Magick::Image.read(
        './spec/support/qr-test.pdf'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code[:amounts]).to eq [{ total: 6_90, vatRate: 0 }]
    end

    it 'extracts a 10% vat rate price from QR code data' do
      image = Magick::Image.read(
        './spec/support/10-percent-vat-qr-code.png'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code[:amounts]).to eq [{ total: 5_90, vatRate: 10 }]
    end

    it 'extracts a 20% vat rate price from QR code data' do
      image = Magick::Image.read(
        './spec/support/20-percent-vat-qr-code.png'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code[:amounts]).to eq [{ total: 60_72, vatRate: 20 }]
    end

    it 'extracts a high price from QR code data' do
      image = Magick::Image.read(
        './spec/support/high-qr-code.jpg'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code[:amounts]).to eq [{ total: 400_00, vatRate: 20 }]
    end

    it 'does not decode a QR code in an unknown format' do
      image = Magick::Image.read(
        './spec/support/unknown-qr-code.png'
      ).first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code).to be_nil
    end

    it 'extracts more than one price from a QR code' do
      image = Magick::Image.read(
        './spec/support/multiple-price-qr-code.png'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code[:amounts]).to eq [
        { total: 15_99, vatRate: 20 }, { total: 7_30, vatRate: 0 }
      ]
    end

    it 'can decode a different value format QR code' do
      image = Magick::Image.read(
        './spec/support/different-value-format-qr-code.pdf'
      ) { self.density = 600 }.first

      decoded_qr_code = QRDecoder.new(image).decode_qr_code
      expect(decoded_qr_code[:dueDate]).to eq '2017-02-14'
      expect(decoded_qr_code[:invoiceDate]).to eq '2017-02-14'
      expect(decoded_qr_code[:amounts]).to eq [{ total: 30_60, vatRate: 13 }]
    end
  end
end
