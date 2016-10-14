# frozen_string_literal: true
FactoryGirl.define do
  sequence :left do |n|
    n * 200
  end

  factory :word do
    to_create(&:save)
    text '12345'
    left
    right { left + 50 }
    top 0
    bottom 20
  end
end
