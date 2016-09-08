require 'sequel'
require_relative './term_builder'
require_relative './date_term'

class BillingPeriodTerm < Sequel::Model
  many_to_one :from, class: DateTerm
  many_to_one :to, class: DateTerm
  def initialize(attrs)
    @term_builder = TermBuilder.new(
      regex: attrs.delete(:regex),
      after_each_word: attrs.delete(:after_each_word)
    )
    super
  end

  def add_word(word)
    @term_builder.add_word(word)
    self.text = word.text
    self.to = word.to
    self.from = word.from
  end
end
