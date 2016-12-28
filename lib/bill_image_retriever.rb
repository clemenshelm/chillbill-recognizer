# frozen_string_literal: true
require 'tempfile'
require 'open-uri'
require 'aws-sdk'
require 'rmagick'
require_relative './logging.rb'

class UnprocessableFileError < StandardError
  attr_reader :extension
  def initialize(file, message = 'Unprocessable file type: ')
    extension = file[:extension]
    version_message = '. Recognizer version: ' + file[:version]
    super(message + extension + version_message)
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
    when '.pdf', '.png', '.jpg', '.jpeg'
      image_file
    else
      require 'yaml'
      data = YAML.load_file('lib/version.yml')
      recognizer_version = data['Version']
      failing_file = {
        extension: file_extension,
        version: recognizer_version.to_s
      }
      raise UnprocessableFileError, failing_file
    end
  end
end
