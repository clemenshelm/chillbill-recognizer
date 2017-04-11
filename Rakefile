# frozen_string_literal: true
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
  training_values = amount_tuples.map do |tuple|
    [tuple['vat_rate'], tuple['common_width'], tuple['common_height']]
  end
  max_values = training_values.reduce([0, 0, 0]) do |max, current|
    max.zip(current).map(&:max).map(&:to_f)
  end
  puts max_values.inspect
  scaled_training_values = training_values.map do |training_set|
    training_set.zip(max_values).map { |t, m| t / m }
  end
  puts scaled_training_values.inspect
  labels = amount_tuples.map { |tuple| tuple['valid_amount'] ? 1 : 0 }
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
