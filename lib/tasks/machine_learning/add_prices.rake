namespace :machine_learning do
  desc 'Add recognized prices to imported bill data'
  task :add_prices do

    require 'yaml/store'
    bill_files = Dir['data/bills/*.yml']
    files_without_prices = bill_files.select do |file|
      bill = YAML.load_file(file)
      bill['total_prices'].nil?
    end

    files_without_prices.each do |file|
      store = YAML::Store.new(file)
      add_prices_to_store(store)
    end
  end

  def add_prices_to_store(store)
    store.transaction do
      puts "Processing bill #{store['_id']} ..."

      recognizer = BillRecognizer.new(image_url: store['image_url'])
      recognizer.empty_database
      png_file = recognizer.download_and_convert_image
      recognizer.recognize_words(png_file)
      recognizer.filter_words

      %w(total_prices_candidates total_prices vat_prices_candidates vat_prices)
        .each { |attr| store[attr] = {} }

      extractor = PriceExtractor.new
      store['amounts'].each do |amount|
        vat_rate = amount['vatRate']

        prices = extractor.extract_prices(for_amount: amount)

        %i(total vat).each do |attr|
          candidates = prices.send(attr)
          price_key = "#{attr}_#{vat_rate}"
          store["#{attr}_prices_candidates"][price_key] = candidates.map(&:to_h)
          store["#{attr}_prices"][price_key] = nil
        end
      end
      store['remaining_prices'] = extractor.remaining_prices.map(&:to_h)
    end
  end

  class PriceExtractor
    attr_reader :remaining_prices

    class Extractor < Struct.new(:amount, :remaining_prices)
      def total
        total_price = BigDecimal.new(amount['total']) / 100
        extract(price: total_price)
      end

      def vat
        vat_rate = amount['vatRate']
        vat_price = (BigDecimal.new(amount['total']) / (100 + vat_rate) * vat_rate / 100).round(2)
        extract(price: vat_price)
      end

      private

      def extract(price:)
        PriceTerm.where(price: price).all.tap do |price_terms|
          self.remaining_prices -= price_terms
        end
      end
    end

    def initialize
      @remaining_prices = PriceTerm.all
    end

    def extract_prices(for_amount:)
      Extractor.new(for_amount, @remaining_prices)
    end
  end
end
