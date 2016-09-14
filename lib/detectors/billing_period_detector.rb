require_relative '../../lib/boot'
require_relative '../word_list'
require_relative './date_detector'
require_relative '../models/billing_period_term'
require_relative '../models/date_term'

class BillingPeriodDetector
  def self.filter
    Word.all.select do |term|
      hyphen_word = Word.where(text: '-')
      bis_word = Word.where(text: 'bis')

      if hyphen_word || bis_word
        binding.pry
        from = DateTerm.right_before(term)
        to = DateTerm.right_after(term)

        if from && to && from.text < to.text
         term =  BillingPeriodTerm.new(
          text: from.text + ' - ' + to.text,
          from: from,
          to: to
          )
          term.save
        end
      end
    end

    BillingPeriodTerm.dataset
  end
end
