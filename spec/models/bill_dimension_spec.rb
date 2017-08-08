# frozen_string_literal: true
require 'open-uri'

describe BillDimension do
  describe '#create_image_dimensions' do
    it 'saves the width of the page' do
      width = [10, 200, 3000].sample
      BillDimension.create_image_dimensions(width: width, height: 20)

      expect(BillDimension.bill_width).to eq(width)
    end

    it 'saves the height of the page' do
      height = [10, 200, 3000].sample
      BillDimension.create_image_dimensions(width: 15, height: height)

      expect(BillDimension.bill_height).to eq(height)
    end
  end

  describe '#bill_ratio' do
    it 'calculates the page ratio' do
      BillDimension.create_image_dimensions(width: 40, height: 20)

      expect(BillDimension.bill_ratio).to eq(2)
    end

    it 'calculates the page ratio as a float' do
      BillDimension.create_image_dimensions(width: 30, height: 20)

      expect(BillDimension.bill_ratio).to eq(1.5)
    end
  end

  describe '#text_box_boundaries' do
    it 'saves the top boundary of the textbox' do
      text_box_top = [10, 200, 3000].sample
      BillDimension.create_text_boundaries(
        top: text_box_top,
        bottom: 10,
        left: 15,
        right: 20
      )

      expect(BillDimension.text_box_top).to eq(text_box_top)
    end

    it 'saves the bottom boundary of the textbox' do
      text_box_bottom = [10, 200, 3000].sample
      BillDimension.create_text_boundaries(
        top: 10,
        bottom: text_box_bottom,
        left: 15,
        right: 20
      )

      expect(BillDimension.text_box_bottom).to eq(text_box_bottom)
    end

    it 'saves the left boundary of the textbox' do
      text_box_left = [10, 200, 3000].sample
      BillDimension.create_text_boundaries(
        top: 10,
        bottom: 15,
        left: text_box_left,
        right: 20
      )

      expect(BillDimension.text_box_left).to eq(text_box_left)
    end

    it 'saves the top boundary of the textbox' do
      text_box_right = [10, 200, 3000].sample
      BillDimension.create_text_boundaries(
        top: 10,
        bottom: 15,
        left: 20,
        right: text_box_right
      )

      expect(BillDimension.text_box_right).to eq(text_box_right)
    end
  end
end
