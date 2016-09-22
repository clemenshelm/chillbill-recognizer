require_relative '../../lib/boot'
require_relative '../word_list'
require_relative './date_detector'
require_relative '../models/billing_period_term'
require_relative '../models/date_term'

class BillingPeriodDetector
  def self.filter
    Word.where(text: ['-', 'bis']).all.select do |term|
      from = DateTerm.right_before(term)
      to = DateTerm.right_after(term)

      next unless from && to
      term =  BillingPeriodTerm.new(
        text: from.text + ' - ' + to.text,
        from: from,
        to: to
      )

      term.save
    end

    BillingPeriodTerm.dataset
  end
end
