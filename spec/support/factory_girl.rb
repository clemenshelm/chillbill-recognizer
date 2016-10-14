# frozen_string_literal: true
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  puts 'loading support!!!'

  config.before(:suite) do
    begin
      # TODO: use database cleaner for unit tests
      # DatabaseCleaner.start
      FactoryGirl.lint
      # ensure
      # DatabaseCleaner.clean
    end
  end
end
