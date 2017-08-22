# frozen_string_literal: true
require_relative 'spec/spec_cache_retriever'
if !ENV['deployment']
  Dir["lib/tasks/machine_learning/*.rake"].each { |file| import file }
end

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

desc 'Check for uncommited changes and correct branch'
task :git_check do
  branch = `branch_name=$(git symbolic-ref HEAD 2>/dev/null); branch_name=${branch_name##refs/heads/}; echo ${branch_name:-HEAD}`.strip
  abort "⛔️  Deployment aborted! You have checked out the #{branch} branch, please only deploy from the master branch!" unless branch == 'master'

  abort "⛔️  Deployment aborted! You have unstaged or uncommitted changes! Please only deploy from a clean working directory!" unless `git status --porcelain`.empty?
end

desc 'Increment recognizer version number'
task :increment_version => [:git_check] do
  require 'YAML'
  data = YAML.load_file "lib/version.yml"
  data["Version"] += 1
  File.open("lib/version.yml", 'w') { |f| YAML.dump(data, f) }

  sh "git add lib/version.yml

      git commit -m 'Increase version number'

      git push origin master"
end

desc 'Pushes newest docker image to ECS repository'
task :push_image => [:increment_version] do
  sh "(aws ecr get-login --no-include-email --region eu-central-1) | /bin/bash

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

  p "The recognizer task has successfully been restarted!🦑"
end

desc 'Notify Rollbar about deployment so it can autoresolve all errors'
task :notify_rollbar => [:push_image, :restart_task] do
  require 'YAML'
  data = YAML.load_file "lib/version.yml"
  recognizer_version = data["Version"]
  access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  sh "curl https://api.rollbar.com/api/1/deploy/ -F access_token=#{access_token} -F environment=production -F revision=#{recognizer_version}"
end

desc 'Increments recognizer version number and deploys newest version'
task :deploy => [:notify_rollbar] do
  p "Newest recognizer version successfully deployed!✌️"
end

desc 'Gains access to parent image and builds recognizer image'
task :build do
  sh "(aws ecr get-login --region eu-central-1) | /bin/bash

      docker pull 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-envd:latest

      docker build -t recognizer-repo ."

  p "The recognizer image was successfully built!✨"
end
