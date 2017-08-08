# frozen_string_literal: true
require 'rollbar'

handler = proc do |options|
  payload = options[:payload]

  payload['data']['environment'] = ENV['RECOGNIZER_ENV']
end

Rollbar.configure do |config|
  config.access_token = '5442c30f1de543ff8769818459f208d4'
  config.transform << handler
end
