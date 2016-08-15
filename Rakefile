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
task :process => :setup_processing do
  process(:unprocessed) do |recognition_result, bill, meteor|
    include Logging

    id = recognition_result.delete :id
    logger.info ["result for bill #{id}:", recognition_result].map(&:to_s)
      .map(&:yellow).join(' ')
    meteor.write_detection_result(id, recognition_result)
  end
end

desc "Check which of the done bills weren't recognized correctly"
task :check => :setup_processing do
  require 'colorize'
  require_relative './lib/logging'

  process(:reviewed) do |recognition_result, bill|
    include Logging

    attributes = %i(amounts invoiceDate vatNumber)
    correct_result = bill[:accountingRecord].slice(*attributes)
    id = recognition_result.delete(:id)
    if recognition_result == correct_result
      logger.info "✔︎ bill #{id}".green
    else
      logger.info [
        "✘ bill #{id}",
        'recognition result:',
        recognition_result,
        'correct result',
        correct_result
      ].map(&:to_s).map(&:red).join(' ')
    end
  end
end

def process(bill_kind, &bill_proc)
  require 'erb'
  require 'yaml'
  require_relative 'lib/hub'

  environment = ENV['RECOGNIZER_ENV'] || 'development'
  config_yaml = ERB.new(IO.read('config.yml')).result
  config = YAML.load(config_yaml)[environment].freeze

  hub = Hub.new(bills: bill_kind, config: config)
  hub.run(&bill_proc)
end
