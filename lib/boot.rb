# frozen_string_literal: true
require 'sequel'

# create in-memory database
DB = Sequel.sqlite

DB.create_table :words do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :price_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :date_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
  Integer :first_word_id
end

DB.create_table :vat_number_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :iban_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :billing_period_terms do
  primary_key :id
  foreign_key :from_id, :date_terms
  foreign_key :to_id, :date_terms
end

DB.create_table :currency_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :due_date_label_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :relative_date_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :invoice_date_label_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :billing_start_label_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :billing_end_label_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :invoice_number_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

DB.create_table :invoice_number_label_terms do
  primary_key :id
  String :text
  Float :left
  Float :right
  Float :top
  Float :bottom
end

Sequel::Model.db = DB
