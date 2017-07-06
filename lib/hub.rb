# frozen_string_literal: true
require './rollbar'
require 'eventmachine'
require 'metybur'
require 'em-hiredis'
require_relative '../sidekiq'
require 'sidekiq/api'
require_relative './logging'

class Hub
  include Logging

  def initialize(bills: 'unprocessed', config:, queue:)
    @bills = bills
    @config = config
    @queue = queue
  end

  def run
    bills = {}

    EventMachine.run do
      redis = EM::Hiredis.connect 'redis://redis:6379'
      Sidekiq::Queue.all.map(&:💣) # Delete all sidekiq jobs
      logger.debug 'running'

      Metybur.log_level = :debug
      meteor = Metybur.connect(
        @config['url'],
        email: @config['meteor']['email'],
        password: @config['meteor']['password']
      )

      meteor.subscribe("admin.bills.#{@bills}")

      meteor.collection('bills')
            .on(:added) do |id, bill|
        logger.info "bill #{id} was added: #{bill}"
        bills[id] = bill

        Sidekiq::Client.enqueue_to(
          @queue,
          RecognitionWorker,
          id,
          bill[:imageUrl],
          bill[:customerVatNumber]
        )
      end

      redis.pubsub.subscribe 'results' do |bill_json|
        recognition_result = JSON.parse bill_json, symbolize_names: true
        id = recognition_result[:id]
        yield(recognition_result, bills[id], meteor)
      end
    end
  rescue Exception => e # rubocop:disable Lint/RescueException
    Rollbar.error(e)
    raise e
  end
end
