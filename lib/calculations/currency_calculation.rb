# frozen_string_literal: true
class CurrencyCalculation
  def initialize(words)
    @words = words
  end

  def iso
    return nil if @words.empty?
    @words.first.to_iso
  end
end
