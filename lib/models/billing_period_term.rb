# frozen_string_literal: true
require 'sequel'
require_relative '../boot'

class BillingPeriodTerm < Sequel::Model
  # Loading it here resolves issues with the circular dependency
  require_relative './date_term'
  many_to_one :from, class: DateTerm
  many_to_one :to, class: DateTerm
end
