require 'sidekiq'
require 'hiredis'
require_relative 'lib/bill_recognizer'

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'jobs', size: 1, url: 'redis://redis' } # Run only 1 thread.
  puts 'Sidekiq client configured.'
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'jobs', url: 'redis://redis' }
  puts 'Sidekiq server configured.'
end

REDIS = Redis.new(driver: :hiredis, host: 'redis')

class RecognitionWorker
  include Sidekiq::Worker

  def perform(id, bill_image_url)
    puts "performing recognition on #{bill_image_url}"
    recognizer = BillRecognizer.new(image_url: bill_image_url)
    bill_attributes = recognizer.recognize
    bill_attributes[:id] = id
    puts bill_attributes
    REDIS.publish 'results', bill_attributes.to_json
  end
end
