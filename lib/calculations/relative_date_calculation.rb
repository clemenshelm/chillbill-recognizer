# frozen_string_literal: true

class RelativeDateCalculation
  def initialize(words)
    @words = words
  end

  def relative_date(date_relative_to)
    return nil if @words.empty?

    if RelativeDateTerm.first.text == 'prompt'
      date_relative_to
    end
  end
end
