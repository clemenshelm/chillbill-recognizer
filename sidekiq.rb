require 'sidekiq'
require 'hiredis'

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'jobs', size: 1 } # Run only 1 thread.
  puts 'Sidekiq client configured.'
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'jobs' }
  puts 'Sidekiq server configured.'
end

REDIS = Redis.new(driver: :hiredis)

class RecognitionWorker
  include Sidekiq::Worker

  def perform(id, bill_image_url)
    puts "performing recognition on #{bill_image_url}"
    # TODO: perform recognition
    REDIS.publish 'results', {id: id}.to_json
  end
end
