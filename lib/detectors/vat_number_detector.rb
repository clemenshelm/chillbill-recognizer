require 'valvat'
require_relative '../word_list'
require_relative '../models/vat_number_term'
require_relative '../logging.rb'

class VatNumberDetector
  include Logging

  VAT_REGEX = /[A-Z]{2}[A-Z0-9]{2,12}/

  def self.filter
    detected_vats = find_vat_numbers(VAT_REGEX)
    detected_vats.each do |term|
      if Valvat.new(term.to_s).valid?
        term.save
      end
    end

    VatNumberTerm.dataset
  end

  private

  def self.find_vat_numbers(regex, after_each_word: nil)
    term = VatNumberTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    median_height = Word.map(&:height).sort[Word.count / 2]
    terms = Word.where('bottom - top <= ?', median_height * 1.15).map do |word|
      if term.exists? || (last_word && !word.follows(last_word))
        term = VatNumberTerm.new(regex: regex, after_each_word: after_each_word)
      end
      term.add_word(word)
      last_word = word
      if term.valid?
        term
      end
    end
    terms.compact
  end


end
