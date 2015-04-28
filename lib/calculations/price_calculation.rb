require 'bigdecimal'

class PriceCalculation
  def initialize(words)
    @words = words 
  end

  def net_amount
    calculate unless @net_amount
    @net_amount
  end

  def vat_amount
    calculate unless @vat_amount
    @vat_amount
  end

  private

  def prices
    @words
      .map(&:text)
      .map { |price_text| BigDecimal.new(price_text.sub(',', '.')) }.uniq
  end

  def calculate
    prices.each do |total|
      remaining_prices = prices - [total]
      remaining_prices.each do |net|
        possible_vats = remaining_prices.select { |price| price <= (net * BigDecimal('0.2')).ceil(2) }
        possible_vats.each do |vat|
          if net + vat == total
            @net_amount = net
            @vat_amount = vat
          end
        end
      end
    end
  end
end
