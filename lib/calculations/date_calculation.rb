class DateCalculation
  def initialize(words)
    @words = words
  end

  def invoice_date
    return nil if @words.empty?

    first_date = @words.first.text
    case first_date
    when /\d+\.\d+\.\d{4}/
      DateTime.parse(@words.first.text)
    when DateDetector::FULL_GERMAN_DATE_REGEX
      DateTime.strptime(@words.first.text, '%d. %B %Y')
    else
      DateTime.strptime(@words.first.text, '%d.%m.%y')
    end
  end
end
