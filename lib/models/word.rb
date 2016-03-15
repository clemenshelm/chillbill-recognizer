require 'sequel'

# TODO unit test
class Word < Sequel::Model
  def next
    Word[id + 1]
  end

  def self_and_following
    selfid = id
    Word.where { id >= selfid }
  end

  def width
    right - left
  end
end
