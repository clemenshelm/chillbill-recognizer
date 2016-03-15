require 'bigdecimal'

class PriceCalculation
  def initialize(words)
    @words = words
  end

  def net_amount
    return nil if @words.empty?
    calculate unless @net_amount
    @net_amount
  end

  def vat_amount
    return nil if @words.empty?
    calculate unless @vat_amount
    @vat_amount
  end

  private

  def calculate
    net_and_vat
    largest_net unless @net_amount
    right_most_net unless @net_amount
  end

  def net_and_vat
    # Sort largest to smallest, because we want to find the higest total amount.
    @words.sort_by(&:to_d).reverse.each do |total_word|
      remaining_prices = (@words - [total_word]).map(&:to_d)
      # Sort smallest to largest. Otherwise the net amount is easily considered
      # the same as the total amount.
      remaining_prices.reverse.each do |net|
        possible_vats = remaining_prices.select { |price| price <= (net * BigDecimal('0.2')).ceil(2) }
        possible_vats.each do |vat|
          if net + vat == total_word.to_d
            @net_amount = net
            @vat_amount = vat
            return
          end
        end
      end
    end
  end

  def largest_net
    # TODO: This would probably be more robust if the net amount needed to be
    # significantly larger.
    largest = @words.sort_by { |word| word.bounding_box.height }.last
    @net_amount = BigDecimal.new(largest.text.sub(',', '.'))
    @vat_amount = 0
  end

  def right_most_net
    right_most = @words.sort_by { |price| price.bounding_box.x }.last
    @net_amount = BigDecimal.new(right_most.text.sub(',', '.'))
    @vat_amount = 0
  end
end
