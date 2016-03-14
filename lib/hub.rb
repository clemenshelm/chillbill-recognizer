require 'eventmachine'
require 'metybur'
require 'em-hiredis'
require_relative '../sidekiq'
require 'sidekiq/api'

class Hub
  def initialize(bills: 'unprocessed', config:)
    @bills = bills
    @config = config
  end

  def run(&bill_proc)
    bills = {}

    EventMachine.run do
      redis = EM::Hiredis.connect 'redis://redis:6379'
      Sidekiq::Queue.new.clear # Delete all sidekiq jobs
      puts 'running'

      Metybur.log_level = :debug
      meteor = Metybur.connect(
        @config['url'],
        email: @config['meteor']['email'],
        password: @config['meteor']['password']
      )

      meteor.subscribe("#{@bills}-bills")

      meteor.collection('bills')
        .on(:added) do |id, bill|
          puts "bill was added: #{bill}"
          bills[id] = bill
          RecognitionWorker.perform_async id, bill[:imageUrl]
        end

      redis.pubsub.subscribe 'results' do |bill_json|
        recognition_result = JSON.parse bill_json, symbolize_names: true
        id = recognition_result[:id]
        bill_proc.call(recognition_result, bills[id], meteor)
      end
    end
  end
end
