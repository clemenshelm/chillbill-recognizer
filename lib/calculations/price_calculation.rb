# frozen_string_literal: true
require 'bigdecimal'

class PriceCalculation
  def net_amount
    return nil if PriceTerm.empty?
    calculate unless @net_amount
    @net_amount * 100
  end

  def vat_amount
    return nil if PriceTerm.empty?
    calculate unless @vat_amount
    @vat_amount * 100
  end

  private

  def calculate
    net_and_vat
    largest_net unless @net_amount
    right_most_net unless @net_amount
  end

  def net_and_vat
    # Sort largest to smallest, because we want to find the higest total amount.
    PriceTerm.sort_by(&:to_d).reverse.each do |total_word|
      remaining_prices = (PriceTerm.all - [total_word]).map(&:to_d)
      # Sort smallest to largest. Otherwise the net amount is easily considered
      # the same as the total amount.
      remaining_prices.reverse.each do |net|
        calculate_and_assign_net_and_vat(remaining_prices, net, total_word)
        break if @net_amount
      end
    end
  end

  def calculate_and_assign_net_and_vat(remaining_prices, net, total_word)
    calculate_possible_vats(remaining_prices, net).each do |vat|
      next unless net + vat == total_word.to_d
      @vat_amount = vat
      @net_amount = net
    end
  end

  def calculate_possible_vats(remaining_prices, net)
    remaining_prices.select do |price|
      price <= (net * BigDecimal('0.2')).ceil(2)
    end
  end

  def largest_net
    # TODO: This would probably be more robust if the net amount needed to be
    # significantly larger.
    largest = PriceTerm.sort_by(&:height).last
    @net_amount = largest.to_d
    @vat_amount = 0
  end

  def right_most_net
    right_most = PriceTerm.sort_by(&:right).last
    @net_amount = BigDecimal.new(right_most.text.sub(',', '.'))
    @vat_amount = 0
  end
end
