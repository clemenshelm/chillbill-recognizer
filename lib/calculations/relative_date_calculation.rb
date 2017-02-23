# frozen_string_literal: true
require_relative '../detectors/relative_date_detector'
require_relative '../boot'

class RelativeDateCalculation
  def relative_date(date_relative_to)
    return nil if RelativeDateTerm.empty?

    date_relative_to if
      RelativeDateDetector::SAME_DAY_TERMS.include?(RelativeDateTerm.first.text)
  end
end
