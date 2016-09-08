require_relative '../../lib/boot'
require_relative '../word_list'
require_relative './date_detector'
require_relative '../models/billing_period_term'
require_relative '../models/date_term'

class BillingPeriodDetector
  def self.filter
    Word.where(text: '-').map do |hyphen|
      from = DateTerm.right_before(hyphen)
      to = DateTerm.right_after(hyphen)

      if from && to
       term =  BillingPeriodTerm.new(
        text: from.text + ' - ' + to.text,
        from: from,
        to: to
        )
        term.save
      end
    end

    BillingPeriodTerm.dataset
  end
end
