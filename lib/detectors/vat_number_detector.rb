# frozen_string_literal: true
require 'valvat'
require_relative '../models/vat_number_term'
require_relative '../logging.rb'

class VatNumberDetector
  include Logging

  VAT_REGEX = /[A-Za-z]{2}[A-Z0-9a-z]{7,12}/
  EU_VAT_REGEX = /EU[0-9]{9}/

  def self.filter
    return VatNumberTerm.dataset if Word.all.empty?
    detected_vats = find_vat_numbers(VAT_REGEX)
    detected_vats
      .select { |term| term.text[EU_VAT_REGEX] || Valvat.new(term.to_s).valid? }
      .each(&:save)

    VatNumberTerm.dataset
  end

  class << self
    private

      def find_vat_numbers(regex, after_each_word: nil)
        term = nil
        last_word = nil
        term_stale = true

        median_height = Word.map(&:height).sort[Word.count / 2]
        scale_factor = median_height > 0.01 ? 1.15 : 1.5

        terms = Word.where(
          'bottom - top <= ?', median_height * scale_factor
        ).map do |word|
          if term_stale || (last_word && !word.follows(last_word))
            term = VatNumberTerm.new(
              regex: regex,
              after_each_word: after_each_word,
              max_words: 4
            )
          end

          term.add_word(word)

          last_word = word
          term_stale = term.valid_subterm
        end
        terms.compact
      end
  end
end
