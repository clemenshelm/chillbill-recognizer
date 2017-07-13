# frozen_string_literal: true
require 'sequel'
require_relative './term'

class InvoiceNumberLabelTerm < Sequel::Model
  include Term
end
