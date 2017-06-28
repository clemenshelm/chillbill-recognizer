# frozen_string_literal: true
require 'sequel'
require_relative './term'

class InvoiceDateLabelTerm < Sequel::Model
  include Term
end
