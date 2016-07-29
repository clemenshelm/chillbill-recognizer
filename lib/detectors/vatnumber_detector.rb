require_relative '../word_list'
require_relative '../models/vatnumber_term'

class VatNumberDetector

  AUSTRIAN_VAT_REGEX = /ATU\d{8}/

  def self.filter
    find_vatnumber(AUSTRIAN_VAT_REGEX)

    VatNumberTerm.dataset
  end


  private

  def self.find_vatnumber(regex, after_each_word: nil)
    term = VatNumberTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    Word.each do |word|
      if term.exists? || (last_word && !word.follows(last_word))
        term = VatNumberTerm.new(regex: regex, after_each_word: after_each_word)
      end
      term.add_word(word)

      last_word = word

      if term.valid?
        term.save
      end
    end
  end
end
