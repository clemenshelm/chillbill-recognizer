# frozen_string_literal: true
require 'open-uri'

describe BillDimension do
  describe '#create_all' do
    it 'saves the width of the page' do
      width = [10, 200, 3000].sample
      BillDimension.create_all(width: width, height: 20)

      expect(BillDimension.bill_width).to eq(width)
    end

    it 'saves the height of the page' do
      height = [10, 200, 3000].sample
      BillDimension.create_all(width: 15, height: height)

      expect(BillDimension.bill_height).to eq(height)
    end
  end

  describe '#bill_ratio' do
    it 'calculates the page ratio' do
      BillDimension.create_all(width: 40, height: 20)

      expect(BillDimension.bill_ratio).to eq(2)
    end

    it 'calculates the page ratio as a float' do
      BillDimension.create_all(width: 30, height: 20)

      expect(BillDimension.bill_ratio).to eq(1.5)
    end
  end

  describe '#define_text_box' do
    it 'saves the top boundary of the textbox' do
      top_boundary = [10, 200, 3000].sample
      BillDimension.define_text_box(
        top_boundary: top_boundary,
        bottom_boundary: 10,
        left_boundary: 15,
        right_boundary: 20
      )

      expect(BillDimension.top_boundary).to eq(top_boundary)
    end

    it 'saves the bottom boundary of the textbox' do
      bottom_boundary = [10, 200, 3000].sample
      BillDimension.define_text_box(
        top_boundary: 10,
        bottom_boundary: bottom_boundary,
        left_boundary: 15,
        right_boundary: 20
      )

      expect(BillDimension.bottom_boundary).to eq(bottom_boundary)
    end

    it 'saves the left boundary of the textbox' do
      left_boundary = [10, 200, 3000].sample
      BillDimension.define_text_box(
        top_boundary: 10,
        bottom_boundary: 15,
        left_boundary: left_boundary,
        right_boundary: 20
      )

      expect(BillDimension.left_boundary).to eq(left_boundary)
    end

    it 'saves the right boundary of the textbox' do
      right_boundary = [10, 200, 3000].sample
      BillDimension.define_text_box(
        top_boundary: 10,
        bottom_boundary: 15,
        left_boundary: 20,
        right_boundary: right_boundary
      )

      expect(BillDimension.right_boundary).to eq(right_boundary)
    end
  end
end
