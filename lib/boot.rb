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
  Integer :first_word_id
end

DB.create_table :vat_number_terms do
  primary_key :id
  String :text
  Integer :left
  Integer :right
  Integer :top
  Integer :bottom
end

<<<<<<< HEAD
DB.create_table :billing_period_terms do
  primary_key :id
  String :text
  Integer :from_id
  Integer :to_id
end

=======
DB.create_table :currency_terms do
  primary_key :id
  String :text
  Integer :left
  Integer :right
  Integer :top
  Integer :bottom
end
>>>>>>> 49ad21a31fcd38e9b906e1277d46e38b99841879
Sequel::Model.db = DB
