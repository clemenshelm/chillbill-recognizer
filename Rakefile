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
  process(:unprocessed) do |recognition_result, _bill, meteor|
    include Logging

    id = recognition_result.delete :id
    logger.info ["result for bill #{id}:", recognition_result].map(&:to_s)
      .map(&:yellow).join(' ')
    meteor.write_detection_result(id, recognition_result)
  end
end

desc "Check which of the done bills weren't recognized correctly"
task check: :setup_processing do
  require 'colorize'
  require_relative './lib/logging'

  process(:reviewed) do |recognition_result, bill|
    include Logging

    attributes = %i(
      amounts
      invoiceDate
      vatNumber
      billingPeriod
      currencyCode
      dueDate
      iban
    )

    correct_result = bill[:accountingRecord].slice(*attributes)
    id = recognition_result.delete(:id)
    if recognition_result == correct_result
      logger.info "✔︎ bill #{id}".green
    else
      logger.info [
        "✘ bill #{id}",
        'recognition result:',
        recognition_result,
        'correct result',
        correct_result
      ].map(&:to_s).map(&:red).join(' ')
    end
  end
end

def process(bill_kind, &bill_proc)
  require 'erb'
  require 'yaml'
  require_relative 'lib/hub'

  environment = ENV['RECOGNIZER_ENV'] || 'development'
  config_yaml = ERB.new(IO.read('config.yml')).result
  config = YAML.load(config_yaml)[environment].freeze

  hub = Hub.new(bills: bill_kind, config: config)
  hub.run(&bill_proc)
end

desc 'Pushes newest docker image to ECS repository'
task :deploy do
  sh "(aws ecr get-login --region eu-central-1) | /bin/bash

      docker build -t recognizer-repo .

      docker tag recognizer-repo:latest 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-repo:latest

      docker push 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-repo:latest"
end

desc 'Restart task on ECS'
task :restart_task do
  sh "aws ecs stop-task --cluster arn:aws:ecs:eu-central-1:175255700812:cluster/chillbill --task arn:aws:ecs:eu-central-1:175255700812:task/8f739435-ca79-43fb-84f1-869f5455d3eb

      aws ecs start-task --cluster arn:aws:ecs:eu-central-1:175255700812:cluster/chillbill --task-definition arn:aws:ecs:eu-central-1:175255700812:task/ecscompose-recognizer:32 --container-instances arn:aws:ecs:eu-central-1:175255700812x:container-instance/f8742655-f231-48ed-ab0d-a2aa92d94117"
end
