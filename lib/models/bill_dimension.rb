# frozen_string_literal: true
require 'sequel'

class BillDimension < Sequel::Model
  class << self
    def create_all(width:, height:)
      BillDimension.create(name: 'bill_width', dimension: width)
      BillDimension.create(name: 'bill_height', dimension: height)
    end

    %w(
      bill_width bill_height text_box_top text_box_bottom text_box_left text_box_right
    ).each do |dimension_name|
      define_method(dimension_name) do
        BillDimension.find(name: dimension_name).dimension
      end
    end

    def bill_ratio
      bill_width / bill_height
    end

    def text_box_boundaries(top:, bottom:, left:, right:)
      BillDimension.create(name: 'text_box_top', dimension: top)
      BillDimension.create(name: 'text_box_bottom', dimension: bottom)
      BillDimension.create(name: 'text_box_left', dimension: left)
      BillDimension.create(name: 'text_box_right', dimension: right)
    end
  end
end
