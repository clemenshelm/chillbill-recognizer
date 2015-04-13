#!/bin/ruby
require 'eventmachine'
require 'ruby-ddp-client'

posts = nil
EventMachine.run do
  ddp_client = RubyDdp::Client.new('localhost', 3000)
  puts 'running'

  ddp_client.onconnect = lambda do |event|
    puts 'connected'

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
puts posts
