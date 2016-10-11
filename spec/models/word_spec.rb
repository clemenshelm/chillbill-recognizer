require_relative '../../lib/boot'
require_relative '../../lib/models/word'

describe 'recognizing words' do
  Word.dataset.delete

  it 'next function works properly' do
    word1 = Word.create(text: "Hello", left: 100, right: 250, top: 300, bottom: 10)
    word2 = Word.create(text: "World", left: 120, right: 270, top: 320, bottom: 30)

    expect(word1.next).to eq word2
  end

  it 'follows function does work' do
    word1 = Word.create(text: "Hello", left: 100, right: 250, top: 300, bottom: 10)
    word2 = Word.create(text: "World", left: 120, right: 270, top: 320, bottom: 30)

    expect(word1.follows(word2)).to eq false
  end
end
