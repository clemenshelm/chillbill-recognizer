source 'https://rubygems.org'
ruby '2.2.2'

gem 'ruby-ddp-client', github: 'clemenshelm/ruby-ddp-client'

# Sidekiq performs a job for each unprocessed invoice.
gem 'sidekiq'

# Used for communicating recognition results
gem 'em-hiredis' # Inside event machine
gem 'redis'      # and outside

# Tesseract is used as OCR engine.
gem 'tesseract-ocr'

# Grim extracts pdf pages as images
gem 'grim'

# OpenCV improves the image for OCR
gem 'ruby-opencv'

group :development do
  gem 'rake'
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'rspec'
end
