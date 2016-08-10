require 'tempfile'
require 'grim'
require 'open-uri'
require 'aws-sdk'


class BillImageRetriever
  def initialize(url:)
    @url = url
  end

  def save
    _, bucket, region, key = @url.match(%r{^https://([^\.]+)\.s3[-\.]([^\.]+).amazonaws.com/(.+)$}).to_a
    puts "bucket: #{bucket}, region: #{region}, key: #{key}"

    file_basename = File.basename key
    file_extension = File.extname  file_basename.downcase!
    bill_id = File.basename file_basename, file_extension

    case file_extension
    when ".pdf"
      pdf_file = Tempfile.new ['bill', '.pdf']
      s3 = Aws::S3::Client.new(region: region)
      s3.get_object(bucket: bucket, key: key, response_target: pdf_file)

      image_file = Tempfile.new ['bill', '.png']
      pdf = Grim.reap(pdf_file.path)
      pdf[0].save(image_file.path, width: 3000, quality: 100)
      pdf_file.close!

      image_file
    when ".png", ".jpg", ".jpeg"
      image_file = Tempfile.new ['bill', file_extension]
      s3 = Aws::S3::Client.new(region: region)
      s3.get_object(bucket: bucket, key: key, response_target: image_file)

      image_file
    else
      # logger.warning("Unknow data type")
    end
  end
end
