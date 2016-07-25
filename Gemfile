source 'https://rubygems.org'
ruby '2.3.1'

# Connects to meteor
gem 'metybur'
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

# Grim extracts pdf pages as images
gem 'grim'

# RMagick improves the image for OCR
gem 'rmagick'

# Nokogiri parses tesseract's hOCR
gem 'nokogiri'

# AWS SDK retrieves files from S3
gem 'aws-sdk', '~> 2'

# Database to store and retrieve words from
gem 'sqlite3'
gem 'sequel'

group :development do
  gem 'rake'
  gem 'colorize' # Colorizes shell output
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'guard-rspec', require: false
  gem 'factory_girl', "~> 4.0"
end
