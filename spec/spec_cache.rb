require 'fileutils'
require 'open-uri'
require_relative '../lib/logging.rb'

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
    bucket = 'chillbill-prod'
    region = 'eu-central-1'
    image_path = cache_file(file_basename.to_s) do |path|
      s3 = Aws::S3::Client.new(region: region)
      s3.get_object(bucket: bucket, key: file_basename.to_s, response_target: path)
    end

    file_extension = File.extname file_basename.downcase
    case file_extension
    when '.pdf'
      bill_id = File.basename file_basename, file_extension
      png_path = cache_file("#{bill_id}.png") do |path|
        pdf = Grim.reap(image_path)
        pdf[0].save(path, width: 3000, quality: 100)
      end

      # Put the PNG into a tempfile so it can savely be overwritten
      # and the cached file won't be modified for sure.
      tempfile = Tempfile.new(['cached', '.png'])
      IO.copy_stream(png_path, tempfile)
      # tempfile = Tempfile.new(['cached', '.pdf'])
      # IO.copy_stream(image_path, tempfile)

      tempfile

    when '.png', '.jpeg', '.jpg'
      tempfile = Tempfile.new(['cached', file_extension])
      IO.copy_stream(image_path, tempfile)
      tempfile
    else
      logger.warn('Unknown data type')
    end
  end
end
