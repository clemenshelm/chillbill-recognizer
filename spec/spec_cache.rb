require 'fileutils'
require 'open-uri'

module SpecCache
  def cache_file(file_name)
    dir = File.expand_path("../../tmp/spec_cache/", __FILE__)
    FileUtils.mkdir_p dir
    file_path = File.join(dir, file_name)
    yield file_path unless File.exist?(file_path)
    file_path
  end

  def cache_png(bill_id)
    bucket = 'chillbill-prod'
    region = 'eu-central-1'
    pdf_path = cache_file("#{bill_id}.pdf") do |path|
      s3 = Aws::S3::Client.new(region: region)
      s3.get_object(bucket: bucket, key: "#{bill_id}.pdf", response_target: path)
    end

    png_path = cache_file("#{bill_id}.png") do |path|
      pdf = Grim.reap(pdf_path)
      pdf[0].save(path, width: 3000, quality: 100)
    end

    # Put the PNG into a tempfile so it can savely be overwritten
    # and the cached file won't be modified for sure.
    tempfile = Tempfile.new(['cached', '.png'])
    IO.copy_stream(png_path, tempfile)
    # tempfile = Tempfile.new(['cached', '.pdf'])
    # IO.copy_stream(pdf_path, tempfile)

    tempfile
  end
end
