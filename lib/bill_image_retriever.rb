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

    @image_file = Tempfile.new ['bill', file_extension]

    get_bill_from_s3(region, bucket, key)

    determine_extension_validity(file_extension)
  end

  def get_bill_from_s3(region, bucket, key)
    s3 = Aws::S3::Client.new(region: region)
    s3.get_object(bucket: bucket, key: key, response_target: @image_file)
  end

  def determine_extension_validity(file_extension)
    case file_extension
    when '.pdf', '.png', '.jpg', '.jpeg'
      @image_file
    else
      raise UnprocessableFileError, file_extension
    end
  end
end
