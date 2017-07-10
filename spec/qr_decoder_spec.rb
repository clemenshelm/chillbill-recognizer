# frozen_string_literal: true
require_relative '../lib/qr_decoder'

describe QRDecoder do
  it 'detects that an image contains a QR code' do
    image = Magick::Image.read('./spec/support/qr-test.pdf') { self.density = 600 }.first

    decoder = QRDecoder.new(image)
    expect(decoder.qr_code?).to be true
  end

  it 'detects that an image contains no QR code' do
    image = Magick::Image.read('./spec/support/no-qr-test.pdf') { self.density = 600 }.first

    decoder = QRDecoder.new(image)
    expect(decoder.qr_code?).to be false
  end

  it 'does not manipulate the original image' do
    image = Magick::Image.read('./spec/support/qr-test.pdf') { self.density = 600 }.first
    original_image = image.dup

    decoder = QRDecoder.new(image)
    decoder.qr_code?

    expect(image).to eq original_image
  end

  it 'does not process a non QR code symbol' do
    image = Magick::Image.read('./spec/support/barcode-test.pdf') { self.density = 600 }.first

    decoder = QRDecoder.new(image)
    expect(decoder.qr_code?).to be false
  end
end
