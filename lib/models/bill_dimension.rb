# frozen_string_literal: true
require 'sequel'

class BillDimension < Sequel::Model
  class << self
    def create_all(width:, height:)
      BillDimension.create(name: 'bill_width', dimension: width)
      BillDimension.create(name: 'bill_height', dimension: height)
    end

    %w(
      bill_width bill_height text_top text_bottom text_left text_right
    ).each do |dimension_name|
      define_method(dimension_name) do
        BillDimension.find(name: dimension_name).dimension
      end
    end

    def bill_ratio
      bill_width / bill_height
    end

    def text_box_boundaries(text_top:, text_bottom:, text_left:, text_right:)
      BillDimension.create(name: 'text_top', dimension: text_top)
      BillDimension.create(name: 'text_bottom', dimension: text_bottom)
      BillDimension.create(name: 'text_left', dimension: text_left)
      BillDimension.create(name: 'text_right', dimension: text_right)
    end
  end
end
