require_relative './spec_cache'

class SpecCacheRetriever
  include SpecCache

  def initialize(bill_id:)
    @bill_id = bill_id  
  end

  def save
    path = cache_png(@bill_id)
    # Put the PNG into a tempfile so it can savely be overwritten
    # and the cached file won't be modified for sure.
    tempfile = Tempfile.new(['cached', '.png'])
    IO.copy_stream(path, tempfile)
    tempfile
  end
end
