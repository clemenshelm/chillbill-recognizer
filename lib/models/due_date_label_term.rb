# frozen_string_literal: true
require 'sequel'
require_relative './term'

class DueDateLabelTerm < Sequel::Model
  include Term
end
