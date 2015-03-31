#!/bin/ruby
require 'eventmachine'
require 'ruby-ddp-client'

posts = nil
EventMachine.run do
  ddp_client = RubyDdp::Client.new('localhost', 3000)
  puts 'running'

  ddp_client.onconnect = lambda do |event|
    puts 'connected'
    ddp_client.subscribe('unprocessed-bills', []) do |result|
      puts 'result'
      posts = ddp_client.collections['bills']
      puts ddp_client.collections
      #EM.stop_event_loop
    end

    ddp_client.observe 'bills', %w(added changed) do |id, bill|
      puts "bill was added: #{bill}"
      # TODO: process bills
      bill_attributes = {}
      ddp_client.call :writeDetectionResult, [id, bill_attributes]
    end
  end
end
puts posts
