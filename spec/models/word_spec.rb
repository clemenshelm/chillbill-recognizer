require_relative '../../lib/boot'
require_relative '../../lib/models/word'

describe 'recognizing words' do
  Word.dataset.delete

  it 'next function works properly' do
    word1 = Word.create(text: "Hello", left: 100, right: 250, top: 300, bottom: 300)
    word2 = Word.create(text: "World", left: 120, right: 270, top: 310, bottom: 320)

    expect(word1.next).to eq word2
  end

  it 'follows function does work' do
    word1 = Word.create(text: "Hello", left: 100, right: 250, top: 250, bottom: 300)
    word2 = Word.create(text: "World", left: 120, right: 270, top: 270, bottom: 320)

    expect(word1.follows(word2)).to eq false
  end
end
