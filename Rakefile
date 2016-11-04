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
task :restart_task => [:push_image] do
  system_task = "tasks=$(aws ecs list-tasks --cluster ChillBill)
                runningtask=$(echo $tasks | tr -d \"\ {}\" | cut -d \"[\" -f2 | cut -d \"]\" -f1)
                runningtask=$(sed -e 's/^\"//' -e 's/\"$//' <<<\"$runningtask\")
                echo $runningtask"
  running_task = `#{system_task}`

  sh "aws ecs stop-task --cluster arn:aws:ecs:eu-central-1:175255700812:cluster/ChillBill --task #{running_task}

      aws ecs start-task --cluster arn:aws:ecs:eu-central-1:175255700812:cluster/ChillBill --task-definition arn:aws:ecs:eu-central-1:175255700812:task-definition/ecscompose-recognizer:32 --container-instances arn:aws:ecs:eu-central-1:175255700812:container-instance/f8742655-f231-48ed-ab0d-a2aa92d94117"
end

desc 'Increments recognizer version number and deploys newest version'
task :deploy => [:restart_task] do
  p "Newest recognizer version successfully deployed!"
end
