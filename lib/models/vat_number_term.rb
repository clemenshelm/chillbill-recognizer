# frozen_string_literal: true
require 'sequel'
require_relative './term'

class VatNumberTerm < Sequel::Model
  include Term

  def to_s
    text.upcase
  end
end
