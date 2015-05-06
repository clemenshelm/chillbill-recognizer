#!/bin/ruby
require 'eventmachine'
require 'metybur'
require 'erb'
require 'yaml'
require 'em-hiredis'
require_relative 'sidekiq'

environment = ENV['RECOGNIZER_ENV'] || 'development'
config_yaml = ERB.new(IO.read('config.yml')).result
CONFIG = YAML.load(config_yaml)[environment]

EventMachine.run do
  redis = EM::Hiredis.connect
  puts 'running'

  meteor = Metybur.connect(
    'http://localhost:3000/websocket',
    email: CONFIG['meteor']['email'],
    password: CONFIG['meteor']['password']
  )

  meteor.subscribe('unprocessed-bills')
  
  meteor.collection('unprocessed-bills')
    .on(:added) do |id, bill|
      puts "bill was added: #{bill}"
      RecognitionWorker.perform_async id, bill[:imageUrl]
    end

  redis.pubsub.subscribe 'results' do |bill_json|
    bill_attributes = JSON.parse bill_json
    id = bill_attributes.delete 'id'
    meteor.write_detection_result(id, bill_attributes)
  end
end
