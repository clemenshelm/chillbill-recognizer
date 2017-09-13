# frozen_string_literal: true
# require 'mina/rails'
# require 'mina/git'
# # require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# # require 'mina/rvm'    # for rvm support. (https://rvm.io)
#
# # Basic settings:
# #   domain       - The hostname to SSH to.
# #   deploy_to    - Path to deploy into.
# #   repository   - Git repo to clone from. (needed by mina/git)
# #   branch       - Branch name to deploy. (needed by mina/git)
#
# set :application_name, 'foobar'
# set :domain, 'foobar.com'
# set :deploy_to, '/var/www/foobar.com'
# set :repository, 'git://...'
# set :branch, 'master'

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# set :shared_dirs, fetch(:shared_dirs, []).push('somedir')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end

desc "Deploys the current version to the server."
task :deploy => [:push_image, :restart_task, :notify_rollbar] do
  sh "git add lib/version.yml

      git commit -m 'Increase version number'

      git push origin master"

  p "Newest recognizer version successfully deployed!✌️"
end
#   # uncomment this line to make sure you pushed your local branch to the remote origin
#   # invoke :'git:ensure_pushed'
#   deploy do
#     # Put things that will set up an empty directory into a fully set-up
#     # instance of your project.
#     invoke :'git:clone'
#     invoke :'deploy:link_shared_paths'
#     invoke :'bundle:install'
#     invoke :'rails:db_migrate'
#     invoke :'rails:assets_precompile'
#     invoke :'deploy:cleanup'
#
#     on :launch do
#       in_path(fetch(:current_path)) do
#         command %{mkdir -p tmp/}
#         command %{touch tmp/restart.txt}
#       end
#     end
#   end

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

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
