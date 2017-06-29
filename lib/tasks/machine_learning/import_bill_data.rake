# frozen_string_literal: true
namespace :machine_learning do
  desc 'Import bill data from local mongodb'
  task :import_bill_data do
    require 'mongo'
    require 'yaml/store'
    limit = 10
    existing_ids = Dir['data/bills/*.yml']
                   .map { |f| f.match(%r{([^\/]+)\.yml})[1] }
    client = Mongo::Client.new(ENV['MONGO_READ_URL'], ssl: true, ssl_verify: false)
    bills = client[:bills]
    bills
      .aggregate(
        [
          {
            '$match' => {
              _id: { '$nin': existing_ids },
              status: 'pushed',
              'recognitionStatistics.amountsAreRecognized': true,
              'accountingRecord.amounts.0.vatRate': { '$ne': 0 }
            }
          },
          { '$sample' => { size: 10 } }
        ]
      )
      .each do |bill|
        store = YAML::Store.new("data/bills/#{bill[:_id]}.yml")
        store.transaction do
          store['_id'] = bill[:_id]
          store['image_url'] = bill[:imageUrl]
          store['amounts'] = bill[:accountingRecord][:amounts].map(&:to_h)
        end
      end

    puts "Successfully imported #{limit} bills."
  end
end
