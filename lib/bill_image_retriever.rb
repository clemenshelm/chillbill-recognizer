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

  VALID_EXTENSIONS = ['.pdf', '.png', '.jpg', '.jpeg'].freeze

  def initialize(url:)
    _, @bucket, @region, @key = url.match(
      %r{^https://([^\.]+)\.s3[-\.]([^\.]+).amazonaws.com/(.+)$}
    ).to_a
    logger.debug "bucket: #{@bucket}, region: #{@region}, key: #{@key}"

    @file_extension = File.extname @key.downcase
  end

  def save
    determine_extension_validity
    download_bill_from_s3
  end

  def download_bill_from_s3
    @image_file = Tempfile.new ['bill', @file_extension]
    s3 = Aws::S3::Client.new(region: @region)
    s3.get_object(bucket: @bucket, key: @key, response_target: @image_file)
    @image_file
  end

  def determine_extension_validity
    return raise UnprocessableFileError, @file_extension unless
      VALID_EXTENSIONS.include?(@file_extension)
  end
end
