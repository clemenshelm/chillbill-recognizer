require 'sequel'
require_relative '../boot'

class BillingPeriodTerm < Sequel::Model
  require_relative './date_term' # Loading it here resolves issues with the circular dependency
  many_to_one :from, class: DateTerm
  many_to_one :to, class: DateTerm
end
