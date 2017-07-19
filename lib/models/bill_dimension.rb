# frozen_string_literal: true
require 'sequel'

class BillDimension < Sequel::Model
  class << self
    def create_all(width:, height:)
      BillDimension.create(name: 'bill_width', dimension: width)
      BillDimension.create(name: 'bill_height', dimension: height)
    end

    %w(
      bill_width bill_height top_boundary bottom_boundary left_boundary right_boundary
    ).each do |dimension_name|
      define_method(dimension_name) do
        BillDimension.find(name: dimension_name).dimension
      end
    end

    def bill_ratio
      bill_width / bill_height
    end

    def define_text_box(
      top_boundary:, bottom_boundary:, left_boundary:, right_boundary:
    )
      BillDimension.create(name: 'top_boundary', dimension: top_boundary)
      BillDimension.create(name: 'bottom_boundary', dimension: bottom_boundary)
      BillDimension.create(name: 'left_boundary', dimension: left_boundary)
      BillDimension.create(name: 'right_boundary', dimension: right_boundary)
    end
  end
end
