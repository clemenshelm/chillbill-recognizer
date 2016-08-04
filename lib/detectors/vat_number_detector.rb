require_relative '../word_list'
require_relative '../models/vat_number_term'

class VatNumberDetector

  AUSTRIAN_VAT_REGEX = /ATU\s*\d{8}/
  EU_VAT_REGEX = /EU\s*\d{9}/
  LUXEMBURG_VAT_REGEX = /LU\s*\d{8}/
  GERMAN_VAT_REGEX = /DE\s*\d{9}/
  IRISH_VAT_REGEX = /IE\s*\d{7}[A-Z]/

  def self.filter
    find_vat_number(LUXEMBURG_VAT_REGEX) # This one is run first because Amazon uses two VAT IDs and we need their LU ID.
    find_vat_number(GERMAN_VAT_REGEX) # This one runs second because when LU is not present we need DE
    find_vat_number(AUSTRIAN_VAT_REGEX)
    find_vat_number(EU_VAT_REGEX)
    find_vat_number(IRISH_VAT_REGEX)
    VatNumberTerm.dataset
  end


  private

  def self.find_vat_number(regex, after_each_word: nil)
    term = VatNumberTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    median_height = Word.map(&:height).sort[Word.count / 2]
    Word.where('bottom - top <= ?', median_height).each do |word|
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
