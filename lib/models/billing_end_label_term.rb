# frozen_string_literal: true
require 'sequel'
require_relative './term'

class BillingEndLabelTerm < Sequel::Model
  include Term
end
