require_relative './spec_cache'

class SpecCacheRetriever
  include SpecCache

  def initialize(bill_id:)
    @bill_id = bill_id  
  end

  def save
    path = cache_png(@bill_id)
    File.new(path)
  end
end
