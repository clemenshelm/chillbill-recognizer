# frozen_string_literal: true
require 'tempfile'
require 'open-uri'
require 'aws-sdk'
require 'rmagick'
require_relative './logging.rb'

class UnprocessableFileError < StandardError
  attr_reader :extension
  def initialize(extension, message = 'Unprocessable file type: ')
    @extension = extension
    super(message + extension)
  end
end

class BillImageRetriever
  include Logging
  include Magick

  def initialize(url:)
    @url = url
  end

  def save
    _, bucket, region, key = @url.match(
      %r{^https://([^\.]+)\.s3[-\.]([^\.]+).amazonaws.com/(.+)$}
    ).to_a
    logger.debug "bucket: #{bucket}, region: #{region}, key: #{key}"

    file_extension = File.extname key.downcase

    image_file = Tempfile.new ['bill', file_extension]
    s3 = Aws::S3::Client.new(region: region)
    s3.get_object(bucket: bucket, key: key, response_target: image_file)

    case file_extension
    when '.pdf'
      png_file = Tempfile.new ['bill', '.png']
      im = Image.read(image_file.path)
      im[0].write(png_file.path)
      image = Image.read(image_file.path) { self.density = '300x300' }[0]
      image.change_geometry('3000x3000^') do |cols, rows, img|
        img.resize!(cols, rows)
      end
      gray_image = image.quantize(256, Magick::GRAYColorspace)
      image.destroy!
      gray_image.write(png_file.path)
      gray_image.destroy!
      image_file.close!

      png_file
    when '.png', '.jpg', '.jpeg'
      image_file
    else
      raise UnprocessableFileError, file_extension
    end
  end
end
