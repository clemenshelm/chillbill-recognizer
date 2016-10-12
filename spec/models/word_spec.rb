require_relative '../../lib/boot'
require_relative '../../lib/models/word'

describe 'recognizing words', :focus do
  Word.dataset.delete

  it 'next function works properly' do
    word1 = Word.create(text: "Hello", left: 100, right: 250, top: 300, bottom: 300)
    word2 = Word.create(text: "World", left: 120, right: 270, top: 310, bottom: 320)

    expect(word1.next).to eq word2
  end

  it 'one word follows the other' do
    word1 = Word.create(text: "IHREN", left: 434, right: 526, top: 1684, bottom: 1714)
    word2 = Word.create(text: "EINKAUF!", left: 547, right: 690, top: 1684, bottom: 1714)

    expect(word2.follows(word1)).to eq true
  end

  it 'one word does not follow the other' do
    word1 = Word.create(text: "Danke!", left: 326, right: 179, top: 300, bottom: 330)
    word2 = Word.create(text: "Betrag", left: 400, right: 324, top: 315, bottom: 331)

    expect(word2.follows(word1)).to eq false
  end
end
