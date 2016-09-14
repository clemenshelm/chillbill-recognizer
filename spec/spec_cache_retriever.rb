require_relative './spec_cache'

class SpecCacheRetriever
  include SpecCache

  def initialize(file_basename:)
    @file_basename = file_basename
  end

  def save
    cache_image(@file_basename)
  end
end
