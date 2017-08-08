# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.3.1'

# Connects to meteor
gem 'metybur', '0.4.3'
# There were problems with newer versions of these gems. Somehow the bill id
# didn't get passed when calling meteor.write_detection_result.
# TODO: Investigate this issue before updating.
gem 'eventmachine', '1.0.8'
gem 'websocket-driver', '0.6.2'

# Sidekiq performs a job for each unprocessed invoice.
gem 'sidekiq'

# Used for communicating recognition results
gem 'em-hiredis' # Inside event machine
gem 'redis'      # and outside

# RMagick improves the image for OCR
gem 'rmagick'

# Nokogiri parses tesseract's hOCR
gem 'nokogiri'

# AWS SDK retrieves files from S3
gem 'aws-sdk', '~> 2'

# Database to store and retrieve words from
gem 'sequel'
gem 'sqlite3'

# A logger which does nothing is the default
gem 'null-logger'

# Validates European VAT numbers
gem 'valvat', '~> 0.6.10'

# Ruby linter
gem 'rubocop', require: false

# Machine learning
gem 'rb-libsvm'

# QR Code reader
gem 'zbar', require: false

# Tracks errors
gem 'rollbar'

group :development do
  gem 'colorize' # Colorizes shell output
  gem 'mongo'
  gem 'rake'
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'factory_girl', '~> 4.0'
  gem 'guard-rspec', require: false
  gem 'rspec'
end
