# frozen_string_literal: true
require 'sequel'
require_relative './term'

class BillingStartLabelTerm < Sequel::Model
  include Term
end
