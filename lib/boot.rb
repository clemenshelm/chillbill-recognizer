require 'sequel'

# create in-memory database
DB = Sequel.sqlite

DB.create_table :words do
  primary_key :id
  String :text
  Integer :left
  Integer :right
  Integer :top
  Integer :bottom
end

DB.create_table :price_terms do
  primary_key :id
  String :text
  Integer :left
  Integer :right
  Integer :top
  Integer :bottom
end

DB.create_table :date_terms do
  primary_key :id
  String :text
  Integer :left
  Integer :right
  Integer :top
  Integer :bottom
end

Sequel::Model.db = DB
