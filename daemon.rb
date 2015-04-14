#!/bin/ruby
require 'eventmachine'
require 'ruby-ddp-client'
require 'erb'
require 'yaml'

environment = ENV['RECOGNIZER_ENV'] || 'development'
config_yaml = ERB.new(IO.read('config.yml')).result
CONFIG = YAML.load(config_yaml)[environment]

posts = nil
EventMachine.run do
  ddp_client = RubyDdp::Client.new('localhost', 3000)
  puts 'running'

  ddp_client.onconnect = lambda do |event|
    puts 'connected'

    credentials = {user: {email: CONFIG['meteor']['email']}, password: CONFIG['meteor']['password']}
    ddp_client.call :login, [credentials]  do
      puts 'logged in'

      ddp_client.subscribe('unprocessed-bills', [])

      ddp_client.observe 'unprocessed-bills', 'added' do |id, bill|
        puts "bill was added: #{bill}"
        # TODO: process bills
        bill_attributes = {}
        ddp_client.call :writeDetectionResult, [id, bill_attributes]
      end

      ddp_client.observe 'unprocessed-bills', 'removed' do |id|
        puts "bill was removed: #{id}"
      end
    end
  end
end
puts posts
