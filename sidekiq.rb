# frozen_string_literal: true
require 'sidekiq'
require 'hiredis'
require_relative 'lib/bill_recognizer'
require_relative 'lib/logging'
require 'timeout'

Sidekiq.configure_client do |config|
  # Run only 1 thread.
  config.redis = { size: 1, url: 'redis://redis' }
  puts 'Sidekiq client configured.'
end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis' }
  puts 'Sidekiq server configured.'
end

REDIS = Redis.new(driver: :hiredis, host: 'redis')

class RecognitionWorker
  include Sidekiq::Worker

  def perform(id, image_url, customer_vat_number)
    logger.info "performing recognition on #{image_url}"
    logger.info "for VAT number #{customer_vat_number}"
    Logging.logger = logger

    recognizer = BillRecognizer.new(
      image_url: image_url,
      customer_vat_number: customer_vat_number
    )
    timeout_in_secs = 200
    bill_attributes = Timeout.timeout(timeout_in_secs) { recognizer.recognize }
    bill_attributes[:id] = id
    logger.info bill_attributes
    REDIS.publish 'results', bill_attributes.to_json
  end
end
