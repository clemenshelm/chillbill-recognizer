# frozen_string_literal: true
namespace :machine_learning do
  desc 'Generate CSV files for R from bill data'
  task :generate_csvs do
    require 'csv'
    require 'securerandom'

    bills = Dir['data/bills/*.yml'].map { |f| YAML.load_file(f) }
    add_id = ->(price) { price['_id'] = SecureRandom.uuid }

    CSV.open('data/prices.csv', 'wb') do |prices_csv|
      CSV.open('data/correct_price_tuples.csv', 'wb') do |correct_tuples_csv|
        prices_csv << %w(bill_id price_id text price_cents left right top
                         bottom)
        correct_tuples_csv << %w(bill_id total_id vat_id vat_rate)

        bills.each do |bill|
          existing_total_prices = bill['total_prices']
                                  .select { |_, amount_price| amount_price }
          total_prices = existing_total_prices
                         .map { |_, price| price }
                         .each(&add_id)
          vat_prices = bill['vat_prices']
                       .map { |_, price| price }
                       .each(&add_id)
          remaining_prices = bill['remaining_prices'].each(&method(:add_id))
          all_prices = total_prices + vat_prices + remaining_prices

          # add price rows
          all_prices.each do |price|
            prices_csv << [
              bill['_id'], price['_id'], price['text'], price['price'],
              price['left'], price['right'], price['top'], price['bottom']
            ]
          end

          # add correct tuple rows
          existing_total_prices.each do |key, amount_price|
            vat_rate = key.split('_').last
            vat_price = bill['vat_prices']["vat_#{vat_rate}"]
            correct_tuples_csv << [
              bill['_id'], amount_price['_id'], vat_price['_id'], vat_rate
            ]
          end
        end
      end
    end
  end
end
