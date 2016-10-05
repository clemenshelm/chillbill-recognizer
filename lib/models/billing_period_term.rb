require 'sequel'
require_relative '../boot'
require_relative './term_builder'
require_relative './date_term'

class BillingPeriodTerm < Sequel::Model
  many_to_one :from, class: DateTerm
  many_to_one :to, class: DateTerm

  def to_isoperiod
    
  end
end
