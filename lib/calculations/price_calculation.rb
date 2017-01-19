# frozen_string_literal: true
require 'bigdecimal'

class PriceCalculation
  def initialize(price_terms)
    @price_terms = price_terms
  end

  def net_amount
    return nil if @price_terms.empty?
    calculate unless @net_amount
    @net_amount
  end

  def vat_amount
    return nil if @price_terms.empty?
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
    @price_terms.sort_by(&:to_d).reverse.each do |total_word|
      @remaining_prices = (@price_terms.all - [total_word]).map(&:to_d)
      # Sort smallest to largest. Otherwise the net amount is easily considered
      # the same as the total amount.
      @remaining_prices.reverse.each do |net|
        calculate_possible_vats(net).each do |vat|
          next unless net + vat == total_word.to_d
          @net_amount = net
          @vat_amount = vat
          return
        end
      end
    end
  end

  def calculate_possible_vats(net)
    @remaining_prices.select do |price|
      price <= (net * BigDecimal('0.2')).ceil(2)
    end
  end

  def largest_net
    # TODO: This would probably be more robust if the net amount needed to be
    # significantly larger.
    largest = @price_terms.sort_by(&:height).last
    @net_amount = largest.to_d
    @vat_amount = 0
  end

  def right_most_net
    right_most = @price_terms.sort_by(&:right).last
    @net_amount = BigDecimal.new(right_most.text.sub(',', '.'))
    @vat_amount = 0
  end
end
