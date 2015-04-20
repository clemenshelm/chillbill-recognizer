require 'fileutils'

module Helpers
  def cache_file(file_name)
    dir = File.expand_path("../../tmp/spec_cache/", __FILE__)
    FileUtils.mkdir_p dir
    file_path = File.join(dir, file_name)
    yield file_path unless File.exist?(file_path)
    file_path
  end
end
