# frozen_string_literal: true
require_relative 'spec/spec_cache_retriever'
require_relative 'lib/bill_recognizer'

namespace :tmp do
  desc 'Clears all cached artifacts'
  task :clear do
    files = Dir['./tmp/**/*.*']
    FileUtils.rm(files, verbose: true)
  end
end

task :setup_processing do
  require 'colorize'
  require_relative './lib/logging'
  require 'logger'

  Logging.logger = Logger.new(STDOUT)
end

desc 'Process unprocessed bills'
task process: :setup_processing do
  process(:unprocessed, :to_process_queue) do |recognition_result, _bill, meteor|
    include Logging

    id = recognition_result.delete :id
    logger.info ["result for bill #{id}:", recognition_result].map(&:to_s)
      .map(&:yellow).join(' ')
    meteor.write_detection_result(id, recognition_result)
  end
end

desc 'Reprocess bills from older versions of the processor'
task reprocess: :setup_processing do
  process(:toReprocess, :to_reprocess_queue) do |recognition_result, _bill, meteor|
    include Logging

    id = recognition_result.delete :id
    logger.info ["result for bill #{id}:", recognition_result].map(&:to_s)
      .map(&:yellow).join(' ')
    meteor.write_detection_result(id, recognition_result)
  end
end

desc 'Import bill data from local mongodb'
task :import_bill_data do
  require 'mongo'
  require 'yaml/store'
  existing_ids = Dir['machine_learning/bills/*.yml'].map { |f| f.match(/([^\/]+)\.yml/)[1] }
  client = Mongo::Client.new([ '127.0.0.1:3001' ], database: 'meteor')
  bills = client[:bills]
  bills.find(
    {
      _id: { '$nin': existing_ids },
      status: 'pushed',
      'recognitionStatistics.allAttributesAreRecognized': true,
      'accountingRecord.amounts.0.vatRate': { '$ne': 0 }
    },
    {limit: 10}
  ).each do |bill|
    store = YAML::Store.new("machine_learning/bills/#{bill[:_id]}.yml")
    store.transaction do
      puts bill[:_id]
      store['_id'] = bill[:_id]
      store['image_url'] = bill[:imageUrl]
      store['amounts'] = bill[:accountingRecord][:amounts].map(&:to_h)
    end
  end
end

desc 'Add recognized prices to imported bill data'
task :add_prices do
  require 'yaml/store'
  bill_files = Dir['machine_learning/bills/*.yml']
  files_without_prices = bill_files.select do |file|
    bill = YAML.load_file(file)
    bill['amount_prices'].nil?
  end

  files_without_prices.each do |file|
    store = YAML::Store.new(file)
    store.transaction do
      puts "Processing bill #{store['_id']} ..."

      recognizer = BillRecognizer.new(image_url: store['image_url'])
      recognizer.empty_database
      png_file = recognizer.download_and_convert_image
      recognizer.recognize_words(png_file)
      recognizer.filter_words

      %w(amount_prices_candidates amount_prices vat_prices_candidates vat_prices)
        .each { |attr| store[attr] = {} }

      available_price_terms = PriceTerm.all
      store['amounts'].each do |amount|
        vat_rate = amount['vatRate']

        total_price_key = "total_#{vat_rate}"
        total_price_terms = PriceTerm.where(price: BigDecimal.new(amount['total']) / 100).all
        available_price_terms -= total_price_terms
        store['amount_prices_candidates'][total_price_key] = total_price_terms.map(&:to_h)
        store['amount_prices'][total_price_key] = nil

        vat_price_key = "vat_#{vat_rate}"
        vat_price = (BigDecimal.new(amount['total']) / (100 + vat_rate) * vat_rate / 100).round(2)
        vat_price_terms = PriceTerm.where(price: vat_price).all
        available_price_terms -= vat_price_terms
        store['vat_prices_candidates'][vat_price_key] = vat_price_terms.map(&:to_h)
        store['vat_prices'][vat_price_key] = nil

        store['remaining_prices'] = available_price_terms.map(&:to_h)
      end
    end
  end
end

def add_id(price)
  require 'securerandom'
  return price['_id'] = SecureRandom.uuid
end

desc 'Generate CSV files for R from bill data'
task :generate_csv do
  require 'csv'

  bills = Dir['machine_learning/bills/*.yml'].map { |f| YAML.load_file(f) }

  CSV.open('machine_learning/prices.csv', 'wb') do |prices_csv|
    CSV.open('machine_learning/correct_price_tuples.csv', 'wb') do |correct_price_tuples_csv|
      prices_csv << ['bill_id', 'price_id', 'text', 'price_cents', 'left', 'right', 'top', 'bottom']
      correct_price_tuples_csv << ['bill_id', 'total_id', 'vat_id', 'vat_rate']

      bills.each do |bill|
        existing_amount_prices = bill['amount_prices']
          .select { |key, amount_price| amount_price }
        amount_prices = existing_amount_prices.map { |key, price| price }.each(&method(:add_id))
        vat_prices = bill['vat_prices'].map { |key, price| price }.each(&method(:add_id))
        remaining_prices = bill['remaining_prices'].each(&method(:add_id))
        all_prices = amount_prices + vat_prices + bill['remaining_prices']

        # add price rows
        all_prices.each do |price|
          prices_csv << [bill['_id'], price['_id'], price['text'], price['price'], price['left'],
            price['right'], price['top'], price['bottom']]
        end

        # add correct tuple rows
        existing_amount_prices.each do |key, amount_price|
          vat_rate = key.split('_').last
          vat_price = bill['vat_prices']["vat_#{vat_rate}"]
          correct_price_tuples_csv << [bill['_id'], amount_price['_id'], vat_price['_id'], vat_rate]
        end
      end
    end
  end
end

task :list_bills do
  require 'colorize'
  Dir['machine_learning/bills/*.yml'].each do |file|
    bill = YAML.load_file(file)
    problems = []
    bill['amount_prices'].each do |key, value|
      vat_rate = key.split('_').last
      problems << "No total price with #{vat_rate}% vat" unless value
    end
    bill['vat_prices'].each do |key, value|
      vat_rate = key.split('_').last
      problems << "No vat price with #{vat_rate}% vat" unless value
    end

    bill_label = "Bill #{bill['_id']}"
    if problems.empty?
      puts "👍🏼  #{bill_label}".green
    else
      puts "🙀  #{bill_label} has got the following problems:".red
      problems.each { |p| puts "- #{p}".red }
    end
  end
end

def process(bill_kind, queue, &bill_proc)
  require 'erb'
  require 'yaml'
  require_relative 'lib/hub'

  environment = ENV['RECOGNIZER_ENV'] || 'development'
  config_yaml = ERB.new(IO.read('config.yml')).result
  config = YAML.load(config_yaml)[environment].freeze

  hub = Hub.new(bills: bill_kind, config: config, queue: queue)
  hub.run(&bill_proc)
end

desc 'Increment recognizer version number'
task :increment_version do
  require 'YAML'
  data = YAML.load_file "lib/version.yml"
  data["Version"] += 1
  File.open("lib/version.yml", 'w') { |f| YAML.dump(data, f) }
end

desc 'Pushes newest docker image to ECS repository'
task :push_image => [:increment_version] do
  sh "(aws ecr get-login --region eu-central-1) | /bin/bash

      docker build -t recognizer-repo .

      docker tag recognizer-repo:latest 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-repo:latest

      docker push 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-repo:latest"
end

desc 'Restart task on ECS'
task :restart_task do
  tasks = `aws ecs list-tasks --cluster ChillBill --region eu-central-1`
  running_tasks = tasks.match(/task\/(\w+\W\w+\W\w+\W\w+\W\w+)/)
  if running_tasks
    sh "aws ecs stop-task --cluster ChillBill --task #{running_tasks[1]} --region eu-central-1"
  end

  all_revisions = `aws ecs list-task-definitions --region eu-central-1`
  all_revision_numbers = all_revisions.scan(/recognizer:(\d+)/).flatten
  latest_revision = all_revision_numbers.map {|num| num.to_i}.sort.last

  sh "aws ecs run-task --cluster ChillBill --task-definition ecscompose-recognizer:#{latest_revision} --count 1 --region eu-central-1"
end

desc 'Increments recognizer version number and deploys newest version'
task :deploy => [:push_image, :restart_task] do
  p "Newest recognizer version successfully deployed!"
end
