# frozen_string_literal: true
class RelativeDateCalculation
  def initialize(words)
    @words = words
  end

  def relative_date(date_relative_to)
    return nil if @words.empty?

    date_relative_to if RelativeDateTerm.first.text == 'prompt'
  end
end
