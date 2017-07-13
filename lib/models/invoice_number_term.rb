# frozen_string_literal: true
require 'sequel'
require_relative './term'
require_relative '../boot'
require_relative './dimensionable'

class InvoiceNumberTerm < Sequel::Model
  include Term
  include Dimensionable

  def words
    @term_builder.words.dup
  end
end
