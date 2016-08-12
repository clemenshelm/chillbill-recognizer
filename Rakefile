namespace :tmp do
  desc 'Clears all cached artifacts'
  task :clear do
    files = Dir['./tmp/**/*.*']
    FileUtils.rm(files, verbose: true)
  end
end

desc 'Process unprocessed bills'
task :process do
  require 'colorize'

  process(:unprocessed) do |recognition_result, bill, meteor|
    id = recognition_result.delete :id
    puts ["result for bill #{id}:", recognition_result].map(&:to_s).map(&:yellow)
    meteor.write_detection_result(id, recognition_result)
  end
end

desc "Check which of the done bills weren't recognized correctly"
task :check do
  require 'colorize'

  process(:reviewed) do |recognition_result, bill|
    attributes = %i(amounts invoiceDate vatNumber)
    correct_result = bill[:accountingRecord].slice(*attributes)
    id = recognition_result.delete(:id)
    if recognition_result == correct_result
      puts "✔︎ bill #{id}".green
    else
      puts [
        "✘ bill #{id}",
        'recognition result:',
        recognition_result,
        'correct result',
        correct_result
      ].map(&:to_s).map(&:red)
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
