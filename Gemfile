source 'https://rubygems.org'
ruby '2.2.2'

# Connects to meteor
gem 'metybur'

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
end
