require 'tempfile'
require 'grim'
require 'open-uri'
require 'aws-sdk'
require_relative '../config/logger.rb'


class BillImageRetriever
  def initialize(url:)
    @url = url
  end

  def save
    _, bucket, region, key = @url.match(%r{^https://([^\.]+)\.s3[-\.]([^\.]+).amazonaws.com/(.+)$}).to_a
    puts "bucket: #{bucket}, region: #{region}, key: #{key}"

    file_extension = File.extname key.downcase

    image_file = Tempfile.new ['bill', file_extension]
    s3 = Aws::S3::Client.new(region: region)
    s3.get_object(bucket: bucket, key: key, response_target: image_file)

    case file_extension
    when ".pdf"
      png_file = Tempfile.new ['bill', '.png']
      pdf = Grim.reap(image_file.path)
      pdf[0].save(png_file.path, width: 3000, quality: 100)
      image_file.close!

      png_file
    when ".png", ".jpg", ".jpeg"
      image_file
    else
      LOGGER.warn("Unknow data type, " + file_extension)
    end
  end
end
