# frozen_string_literal: true
require 'sequel'
require_relative './term'
require_relative './dimensionable'

class IbanTerm < Sequel::Model
  include Term
  include Dimensionable

  def to_s
    text.delete(' ')
  end
end
