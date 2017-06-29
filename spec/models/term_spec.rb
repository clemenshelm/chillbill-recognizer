# frozen_string_literal: true
require_relative '../../lib/models/term'
require_relative '../../lib/models/word'

class TermTest < Sequel::Model
  include Term
  attr_accessor :text, :left, :right, :top, :bottom
end

describe Term do
  let(:term) { TermTest.new(regex: /abcdef/) }

  context 'growing dimensions' do
    before(:each) do
      term.add_word(Word.new(text: 'abc', left: 2, right: 4, top: 2, bottom: 4))
    end

    it 'extends the left coordinate of if a new word is further left' do
      term.add_word(Word.new(text: 'def', left: 1, right: 4, top: 2, bottom: 4))

      expect(term.left).to eq(1)
    end

    it 'does not extend the left coordinate of if a new word is not further left' do
      term.add_word(Word.new(text: 'def', left: 3, right: 4, top: 2, bottom: 4))

      expect(term.left).to eq(2)
    end

    it 'extends the right coordinate of if a new word is further right' do
      term.add_word(Word.new(text: 'def', left: 2, right: 5, top: 2, bottom: 4))

      expect(term.right).to eq(5)
    end

    it 'does not extend the right coordinate of if a new word is not further right' do
      term.add_word(Word.new(text: 'def', left: 2, right: 3, top: 2, bottom: 4))

      expect(term.right).to eq(4)
    end

    it 'extends the top coordinate of if a new word is further up' do
      term.add_word(Word.new(text: 'def', left: 2, right: 4, top: 1, bottom: 4))

      expect(term.top).to eq(1)
    end

    it 'does not extend the top coordinate of if a new word is not further up' do
      term.add_word(Word.new(text: 'def', left: 2, right: 4, top: 3, bottom: 4))

      expect(term.top).to eq(2)
    end

    it 'extends the bottom coordinate of if a new word is further down' do
      term.add_word(Word.new(text: 'def', left: 2, right: 4, top: 2, bottom: 5))

      expect(term.bottom).to eq(5)
    end

    it 'does not extend the bottom coordinate of if a new word is not further down' do
      term.add_word(Word.new(text: 'def', left: 2, right: 4, top: 2, bottom: 3))

      expect(term.bottom).to eq(4)
    end
  end

  context 'valid subterm' do
    it 'extracts the minimum valid subterm from a number of words' do
      term.add_word(Word.new(text: 'xxx', left: 0, right: 2, top: 0, bottom: 2))
      term.add_word(Word.new(text: 'abc', left: 3, right: 5, top: 0, bottom: 2))
      term.add_word(Word.new(text: 'def', left: 6, right: 8, top: 1, bottom: 3))

      valid_subterm = term.valid_subterm
      expect(valid_subterm.text).to eq('abcdef')
      expect(valid_subterm.left).to eq(3)
      expect(valid_subterm.right).to eq(8)
      expect(valid_subterm.top).to eq(0)
      expect(valid_subterm.bottom).to eq(3)
    end
  end
end
