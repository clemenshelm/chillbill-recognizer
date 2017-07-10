# frozen_string_literal: true
require_relative '../models/billing_start_label_term'

class BillingStartLabelDetector
  BILLING_START_LABELS = /(Billing Start:)/

  def self.filter
    end_word_with_space = ->(term) { term.text += ' ' }
    find_billing_start_labels(
      BILLING_START_LABELS,
      after_each_word: end_word_with_space
    )
    BillingStartLabelTerm.dataset
  end

  class << self
    private

      def find_billing_start_labels(regex, after_each_word: nil)
        term = nil
        last_word = nil
        term_stale = true

        Word.each do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = BillingStartLabelTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 2
            )
          end

          term.add_word(word)

          last_word = word

          term_stale = term.valid_subterm&.save
        end
      end
  end
end
