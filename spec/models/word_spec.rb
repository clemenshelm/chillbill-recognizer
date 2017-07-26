# frozen_string_literal: true
require_relative '../../lib/boot'

describe 'recognizing words' do
  Word.dataset.delete

  it 'next function works properly' do
    # From BYnCDzw7nNMFergRW.pdf
    word1 = Word.create(
      text: 'Credit',
      left: 0.7303664921465969,
      right: 0.7647251308900523,
      top: 0.650555041628122,
      bottom: 0.6572617946345976
    )

    word2 = Word.create(
      text: 'Card',
      left: 0.768979057591623,
      right: 0.7954842931937173,
      top: 0.650555041628122,
      bottom: 0.6572617946345976
    )

    expect(word1.next).to eq word2
  end

  it 'one word follows the other' do
    # From BYnCDzw7nNMFergRW.pdf
    word1 = Word.create(
      text: 'Additional',
      left: 0.0412303664921466,
      right: 0.1119109947643979,
      top: 0.6082331174838113,
      bottom: 0.6158649398704903
    )

    word2 = Word.create(
      text: 'Information',
      left: 0.11845549738219895,
      right: 0.19731675392670156,
      top: 0.6082331174838113,
      bottom: 0.6158649398704903
    )

    expect(word2.follows(word1)).to eq true
  end

  it 'one word does not follow the other' do
    # From BYnCDzw7nNMFergRW.pdf
    word1 = Word.create(
      text: 'Payment',
      left: 0.04253926701570681,
      right: 0.10176701570680628,
      top: 0.5430157261794635,
      bottom: 0.5527289546716003
    )

    word2 = Word.create(
      text: 'and',
      left: 0.25752617801047123,
      right: 0.2755235602094241,
      top: 0.7155411655874191,
      bottom: 0.7215541165587419
    )

    expect(word2.follows(word1)).to eq false
  end
end
