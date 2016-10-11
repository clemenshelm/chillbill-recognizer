require 'sequel'
require_relative '../boot'
# require_relative './term_builder'

class BillingPeriodTerm < Sequel::Model
  require_relative './date_term' # Loading it here resolves issues with the circular dependency
  many_to_one :from, class: DateTerm
  many_to_one :to, class: DateTerm

  # def initialize(attrs)
  #   @term_builder = TermBuilder.new(
  #     regex: attrs.delete(:regex),
  #     after_each_word: attrs.delete(:after_each_word)
  #   )
  #   super
  # end
  #
  # def add_word(word)
  #   @term_builder.add_word(word)
  #   self.from = word.left
  #   self.to = word.top
  # end
end
