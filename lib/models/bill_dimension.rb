# frozen_string_literal: true
require 'sequel'

class BillDimension < Sequel::Model
  class << self
    def create_all(width:, height:)
      BillDimension.create(name: 'bill_width', dimension: width)
      BillDimension.create(name: 'bill_height', dimension: height)
    end

    %w(bill_width bill_height).each do |dimension_name|
      define_method(dimension_name) do
        BillDimension.find(name: dimension_name).dimension
      end
    end

    def bill_ratio
      bill_width / bill_height
    end
  end
end
