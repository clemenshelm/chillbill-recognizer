#!/bin/ruby
require 'eventmachine'
require 'ruby-ddp-client'
require 'em-hiredis'
require_relative 'sidekiq'

EventMachine.run do
  ddp_client = RubyDdp::Client.new('localhost', 3000)
  redis = EM::Hiredis.connect
  puts 'running'

  ddp_client.onconnect = lambda do |event|
    puts 'connected'

    ddp_client.subscribe('unprocessed-bills', [])

    redis.pubsub.subscribe 'results' do |bill_json|
      bill_attributes = JSON.parse bill_json
      id = bill_attributes.delete 'id'
      ddp_client.call :writeDetectionResult, [id, bill_attributes]
    end

    ddp_client.observe 'unprocessed-bills', 'added' do |id, bill|
      puts "bill was added: #{bill}"
      RecognitionWorker.perform_async id, bill['imageUrl']
    end

    ddp_client.observe 'unprocessed-bills', 'removed' do |id|
      puts "bill was removed: #{id}"
    end
  end
end
