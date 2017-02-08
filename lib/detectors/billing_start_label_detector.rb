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
        term = BillingStartLabelTerm.new(
          regex: regex, after_each_word: after_each_word, max_words: 2
        )
        last_word = nil

        Word.each do |word|
          if term.exists? || (last_word && !word.follows(last_word))
            term = BillingStartLabelTerm.new(
              regex: regex, after_each_word: after_each_word, max_words: 2
            )
          end

          term.add_word(word)

          last_word = word

          term.save if term.valid?
        end
      end
  end
end
