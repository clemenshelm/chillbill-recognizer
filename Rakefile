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
  client = Mongo::Client.new([ '127.0.0.1:3001' ], database: 'meteor')
  bills = client[:bills]
  bills.find(
    {
      status: 'pushed',
      'recognitionStatistics.allAttributesAreRecognized': true,
      'accountingRecord.amounts.0.vatRate': {'$ne': 0}
    },
    {limit: 10}
  ).each do |bill|
    store = YAML::Store.new("machine_learning/invoices/#{bill[:_id]}.yml")
    store.transaction do
      store['_id'] = bill[:_id]
      store['image_url'] = bill[:imageUrl]
      store['amounts'] = bill[:accountingRecord][:amounts].map(&:to_h)
    end
  end
end

task :add_amount_candidates do
  require 'yaml/store'
  Dir['machine_learning/invoices/*.yml'].each do |file|
    store = YAML::Store.new(file)
    store.transaction do
      puts "======="
      puts "Bill #{store['_id']}:"

      recognizer = BillRecognizer.new(image_url: store['image_url'])
      recognizer.empty_database
      png_file = recognizer.download_and_convert_image
      recognizer.recognize_words(png_file)
      recognizer.filter_words

      store['amounts'].each do |amount|
        puts PriceTerm.where(price: amount['total'].to_d * 100)
      end
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
