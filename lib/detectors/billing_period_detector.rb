# frozen_string_literal: true
require_relative '../boot'
require_relative '../models/billing_period_term'
require_relative '../models/date_term'

class BillingPeriodDetector
  def self.filter
    Word.where(text: ['-', 'bis']).all.each do |term|
      from = DateTerm.right_before(term)
      to = DateTerm.right_after(term)

      next unless from && to
      term = BillingPeriodTerm.new(
        from: from, to: to
      )

      term.save
    end

    if BillingStartLabelTerm.any? && BillingEndLabelTerm.any?
      billing_period_start = DateTerm.right_after(
        BillingStartLabelTerm.first
      )

      billing_period_end = DateTerm.right_after(
        BillingEndLabelTerm.first
      )

      BillingPeriodTerm.create(
        from: billing_period_start,
        to: billing_period_end
      )
    end

    BillingPeriodTerm.dataset
  end
end
