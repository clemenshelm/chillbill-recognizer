source 'https://rubygems.org'
ruby '2.2.2'

# Connects to meteor
gem 'metybur'

# Sidekiq performs a job for each unprocessed invoice.
gem 'sidekiq'

# Used for communicating recognition results
gem 'em-hiredis' # Inside event machine
gem 'redis'      # and outside

# Tesseract is used as OCR engine.
gem 'tesseract-ocr'

# Grim extracts pdf pages as images
gem 'grim'

# RMagick improves the image for OCR
gem 'rmagick'

group :development do
  gem 'rake'
  gem 'colorize' # Colorizes shell output
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'rspec'
end
