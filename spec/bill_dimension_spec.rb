# frozen_string_literal: true
require 'open-uri'
require_relative '../lib/models/bill_dimension'

describe BillDimension do
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

  it 'calculates the page ratio' do
    BillDimension.create_all(width: 40, height: 20)

    expect(BillDimension.bill_ratio).to eq(2)
  end

  it 'calculates the page ratio as a float' do
    BillDimension.create_all(width: 30, height: 20)

    expect(BillDimension.bill_ratio).to eq(1.5)
  end
end
