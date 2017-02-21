# frozen_string_literal: true
class RelativeDateCalculation
  def relative_date(date_relative_to)
    return nil if RelativeDateTerm.empty?

    date_relative_to if RelativeDateTerm.first.text == 'prompt' ||
                        RelativeDateTerm.first.text == 'Fällig bei Erhalt' ||
                        RelativeDateTerm.first.text == 'Fällig nach Erhalt'
  end
end
