# frozen_string_literal: true
require_relative '../detectors/iban_detector'

class RelativeDateCalculation
  def initialize(relative_date_terms)
    @relative_date = relative_date
  end

  def relative_date(date_relative_to)
    return nil if @relative_date_terms.empty?
    
    if RelativeDateTerm.first.text == 'prompt'
      date_relative_to
    end
  end
end
