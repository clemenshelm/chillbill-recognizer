# frozen_string_literal: true
require_relative '../models/relative_word_term'

class RelativeWordDetector
  RELATIVE_WORDS = /(prompt)/

  def self.filter
    find_relative_words(RELATIVE_WORDS)
    RelativeWordTerm.dataset
  end

  def self.find_relative_words(regex, after_each_word: nil)
    private
    term = RelativeWordTerm.new(regex: regex, after_each_word: after_each_word)
    last_word = nil

    Word.each do |word|
      if term.exists? || (last_word && !word.follows(last_word))
        term = RelativeWordTerm.new(
          regex: regex, after_each_word: after_each_word
        )
      end

      term.add_word(word)

      last_word = word

      term.save if term.valid?
    end
  end
end