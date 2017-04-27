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

desc 'Execute machine learning test script'
task machine_learning: :setup_processing do
  require 'libsvm'
  require 'yaml'
  problem = Libsvm::Problem.new
  parameter = Libsvm::SvmParameter.new

  parameter.cache_size = 1 # in megabytes

  parameter.eps = 0.001
  parameter.c = 10

  # load training data
  amount_tuples = Dir['machine_learning/training/*.yml'].flat_map do |file|
    YAML.load_file(file)['amount_tuples']
  end
  puts 'amount tuples'
  puts amount_tuples.inspect
  training_values = amount_tuples.map do |tuple|
    [tuple['vat_rate'], tuple['common_width'], tuple['common_height']]
  end
  puts 'training values'
  puts training_values.inspect
  max_values = training_values.reduce([0, 0, 0]) do |max, current|
    max.zip(current).map(&:max).map(&:to_f)
  end
  puts 'max values'
  puts max_values.inspect
  scaled_training_values = training_values.map do |training_set|
    training_set.zip(max_values).map { |t, m| t / m }
  end
  puts 'scaled training values'
  puts scaled_training_values.inspect
  labels = amount_tuples.map { |tuple| tuple['valid_amount'] ? 1 : -1 }
  puts labels.inspect

  examples = scaled_training_values.map {|ary| Libsvm::Node.features(ary) }
  problem.set_examples(labels, examples)

  model = Libsvm::Model.train(problem, parameter)

  # load test data
  test_bill = YAML.load_file "machine_learning/test/kk4FafcZqvCCC64BY.yml"
  test_bill['amount_tuples'].each do |tuple|
    test_set = [tuple['vat_rate'], tuple['common_width'], tuple['common_height']]
    scaled_test_set = test_set.zip(max_values).map { |t, m| t / m }
    pred = model.predict(Libsvm::Node.features(scaled_test_set))
    correct = (pred == 1) == tuple['valid_amount']
    puts correct ? 'correct' : 'wrong'
    puts "Example #{test_set} - Predicted #{pred}"
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
      puts "======="
      puts "Bill #{store['_id']}:"
      puts store['image_url']

      recognizer = BillRecognizer.new(image_url: store['image_url'])
      recognizer.empty_database
      png_file = recognizer.download_and_convert_image
      recognizer.recognize_words(png_file)
      recognizer.filter_words

      store['amount_prices_candidates'] = {}
      store['amount_prices'] = {}
      store['vat_prices_candidates'] = {}
      store['vat_prices'] = {}
      available_price_terms = PriceTerm.all
      store['amounts'].each do |amount|
        vat_rate = amount['vatRate']

        total_price_key = "total_#{vat_rate}"
        total_price_terms = PriceTerm.where(price: BigDecimal.new(amount['total']) / 100).all
        available_price_terms -= total_price_terms
        store['amount_prices_candidates'][total_price_key] = total_price_terms.map do |term|
          {
            'text' => term.text,
            'price' => (term.price * 100).round.to_i,
            'left' => term.left,
            'right' => term.right,
            'top' => term.top,
            'bottom' => term.bottom
          }
        end
        store['amount_prices'][total_price_key] = nil

        vat_price_key = "vat_#{vat_rate}"
        vat_price = (BigDecimal.new(amount['total']) / (100 + vat_rate) * vat_rate / 100).round(2)
        vat_price_terms = PriceTerm.where(price: vat_price).all
        available_price_terms -= vat_price_terms
        store['vat_prices_candidates'][vat_price_key] = vat_price_terms.map do |term|
          {
            'text' => term.text,
            'price' => (term.price * 100).round.to_i,
            'left' => term.left,
            'right' => term.right,
            'top' => term.top,
            'bottom' => term.bottom
          }
        end
        store['vat_prices'][vat_price_key] = nil

        store['remaining_prices'] = available_price_terms.map do |term|
          {
            'text' => term.text,
            'price' => (term.price * 100).round.to_i,
            'left' => term.left,
            'right' => term.right,
            'top' => term.top,
            'bottom' => term.bottom
          }
        end
      end
    end
  end
end

task :generate_csv do
  require 'csv'

  CSV.open('machine_learning/price_tuples.csv', 'wb') do |csv|
    csv << ['id', 'total_price', 'vat_price', 'valid_amount']
    bills = Dir['machine_learning/bills/*.yml'].map { |f| YAML.load_file(f) }
    bills.each do |bill|
      existing_amount_prices = bill['amount_prices']
        .select { |key, amount_price| amount_price }
      # valid tuples
      existing_amount_prices.each do |key, amount_price|
          vat_rate = key.split('_').last
          vat_price = bill['vat_prices']["vat_#{vat_rate}"]
          csv << [bill['_id'], amount_price['price'], vat_price['price'], 1]
        end

      # invalid tuples
      # TODO: Add vat prices, but make sure the correct tuple isn't listed
      amount_prices = existing_amount_prices.map { |key, value| value }
      (bill['remaining_prices'] + amount_prices).each do |total_price|
        vat_candidates = (bill['remaining_prices'] - [total_price])
          .select { |price| price['price'] < total_price['price'] * 0.3 }
        vat_candidates.each do |vat_price|
          csv << [bill['_id'], total_price['price'], vat_price['price'], 0]
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

task :add_price_terms do
  require 'yaml/store'
  Dir['machine_learning/training/*.yml'].each do |file|
    store = YAML::Store.new(file)
    store.transaction do
      puts "======="
      puts "Bill #{store['_id']}:"
      recognizer = BillRecognizer.new(image_url: store['image_url'])
      recognizer.empty_database
      png_file = recognizer.download_and_convert_image
      recognizer.recognize_words(png_file)
      recognizer.filter_words

      amount_tuples = PriceCalculation.new.amount_tuples.each do |tuple|
        tuple[:valid_amount] = store['amounts'].any? do |amount|
          amount['total'] == tuple[:total] && amount['vatRate'] == tuple[:vat_rate]
        end
      end

      valid_tuples = amount_tuples.find_all { |t| t[:valid_amount] }
      unless (valid_tuples.size == store['amounts'].size)
        puts "Valid tuples #{valid_tuples.inspect}"
        puts "amounts: #{store['amounts'].inspect}"
      end
    end
  end
end

desc 'Generate machine learning test data for a bill'
task :generate_test_data do
  retriever = SpecCacheRetriever.new(file_basename: 'GgDYmLfoXxeQ7t8F7.pdf')
  recognizer = BillRecognizer.new(retriever: retriever)

  bill_attributes = recognizer.recognize
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
