namespace :machine_learning do
  desc 'List all imported bills with their status and potential problems'
  task :list_bills do
    require 'colorize'
    Dir['data/bills/*.yml'].each do |file|
      bill = YAML.load_file(file)
      problems = []
      bill['total_prices'].each do |key, value|
        vat_rate = key.split('_').last
        problems << "No total price with #{vat_rate}% vat" unless value
      end
      bill['vat_prices'].each do |key, value|
        vat_rate = key.split('_').last
        problems << "No vat price with #{vat_rate}% vat" unless value
      end

      bill_label = "Bill #{bill['_id']}"
      if problems.empty?
        puts "👍🏼  #{bill_label}".green
      else
        puts "🙀  #{bill_label} has got the following problems:".red
        problems.each { |p| puts "- #{p}".red }
      end
    end
  end
end
