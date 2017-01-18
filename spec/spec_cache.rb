# frozen_string_literal: true
require 'fileutils'
require 'open-uri'
require_relative '../lib/logging.rb'
require 'rmagick'

module SpecCache
  include Logging

  def cache_file(file_name)
    dir = File.expand_path('../../tmp/spec_cache/', __FILE__)
    FileUtils.mkdir_p dir
    file_path = File.join(dir, file_name)
    yield file_path unless File.exist?(file_path)
    file_path
  end

  def cache_image(file_basename)
    file_extension = File.extname file_basename.downcase

    image_path = cache_file(file_basename) do |path|
      download_from_s3(path, file_basename)
    end

    copy_to_tempfile(image_path, file_extension)
  end

  def download_from_s3(path, file_basename)
    s3 = Aws::S3::Client.new(region: 'eu-central-1')
    s3.get_object(
      bucket: 'chillbill-prod',
      key: file_basename,
      response_target: path
    )
  end

  def copy_to_tempfile(image_path, file_extension)
    case file_extension
    when '.pdf', '.png', '.jpeg', '.jpg'
      tempfile = Tempfile.new(['cached', file_extension])
      IO.copy_stream(image_path, tempfile)
      tempfile
    else
      logger.warn('Unknown data type')
    end
  end
end
