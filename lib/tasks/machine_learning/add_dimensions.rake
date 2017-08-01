# frozen_string_literal: true
require_relative '../../bill_recognizer'

namespace :machine_learning do
  desc 'Add recognized prices to imported bill data'
  task :add_dimensions do
    require 'yaml/store'
    bill_files = Dir['data/bills/*.yml']
    files_without_prices = bill_files.select do |file|
      bill = YAML.load_file(file)
      bill['dimensions'].nil?
    end

    files_without_prices.each do |file|
      store = YAML::Store.new(file)
      add_dimensions_to_store(store)
    end
  end

  def add_dimensions_to_store(store)
    store.transaction do
      puts "Processing bill #{store['_id']} ..."

      recognizer = BillRecognizer.new(image_url: store['image_url'])
      recognizer.empty_database
      recognizer.download_and_convert_image
      store['dimensions'] = {
        'width' => BillDimension.bill_width,
        'height' => BillDimension.bill_height,
        'text_box_top' => BillDimension.text_box_top,
        'text_box_bottom' => BillDimension.text_box_bottom,
        'text_box_left' => BillDimension.text_box_left,
        'text_box_right' => BillDimension.text_box_right,
        'bill_type' => 'A4'
      }
    end
  end
end
