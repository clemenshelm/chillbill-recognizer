#!/bin/ruby
require 'eventmachine'
require 'ruby-ddp-client'
require 'erb'
require 'yaml'
require 'em-hiredis'
require_relative 'sidekiq'

environment = ENV['RECOGNIZER_ENV'] || 'development'
config_yaml = ERB.new(IO.read('config.yml')).result
CONFIG = YAML.load(config_yaml)[environment]

EventMachine.run do
  ddp_client = RubyDdp::Client.new('localhost', 3000)
  redis = EM::Hiredis.connect
  puts 'running'

  ddp_client.onconnect = lambda do |event|
    puts 'connected'

    credentials = {user: {email: CONFIG['meteor']['email']}, password: CONFIG['meteor']['password']}
    ddp_client.call :login, [credentials]  do
      puts 'logged in'

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
end
