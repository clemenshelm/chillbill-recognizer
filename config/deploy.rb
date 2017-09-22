# frozen_string_literal: true
desc "Deploys the current version to the server."
task :deploy => [:push_image, :restart_task, :notify_rollbar] do
  sh "git add lib/version.yml

      git commit -m 'Increase version number'

      git push origin master"

  p "Newest recognizer version successfully deployed!✌️"
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
task :notify_rollbar do
  require 'YAML'
  data = YAML.load_file "lib/version.yml"
  recognizer_version = data["Version"]
  access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  sh "curl https://api.rollbar.com/api/1/deploy/ -F access_token=#{access_token} -F environment=production -F revision=#{recognizer_version}"
end

desc 'Gains access to parent image and builds recognizer image'
task :build do
  sh "(aws ecr get-login --no-include-email --region eu-central-1) | /bin/bash

      docker pull 175255700812.dkr.ecr.eu-central-1.amazonaws.com/recognizer-envd:latest

      docker build -t recognizer-repo ."

  p "The recognizer image was successfully built!✨"
end
