# frozen_string_literal: true
require 'sidekiq'
require 'hiredis'
require_relative 'lib/bill_recognizer'
require_relative 'lib/logging'
require 'timeout'

Sidekiq.configure_client do |config|
  # Run only 1 thread.
  config.redis = { namespace: 'jobs', size: 1, url: 'redis://redis' }
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
    logger.info "performing recognition on #{bill_image_url}"
    Logging.logger = logger

    recognizer = BillRecognizer.new(image_url: bill_image_url)
    timeout_in_secs = 120
    bill_attributes = Timeout::timeout(timeout_in_secs) { recognizer.recognize }
    bill_attributes[:id] = id
    logger.info bill_attributes
    REDIS.publish 'results', bill_attributes.to_json
  end
end
