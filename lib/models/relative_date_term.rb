# frozen_string_literal: true
require 'sequel'
require_relative './term'

class RelativeDateTerm < Sequel::Model
  include Term
end
