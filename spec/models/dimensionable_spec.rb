# frozen_string_literal: true
require_relative '../support/factory_girl'
require_relative '../factories'

describe Dimensionable do
  it 'can detect the width of a term' do
    term = DateTerm.new(
      text: '01.03.2015',
      left: 591,
      right: 798,
      top: 773,
      bottom: 809,
      first_word_id: 19
    )

    expect(term.width).to eq 207
  end

  it 'can detect the height of a term' do
    term = DateTerm.new(
      text: '31.03.2015',
      left: 832,
      right: 1038,
      top: 773,
      bottom: 809,
      first_word_id: 26
    )

    expect(term.height).to eq 36
  end

  it 'can detect the term before another term' do
    DateTerm.create(
      text: '10.04.2015',
      left: 2194,
      right: 2397,
      top: 213,
      bottom: 248
    )

    DateTerm.create(
      text: '15.04.2015',
      left: 2194,
      right: 2397,
      top: 274,
      bottom: 309
    )

    previous_term = DateTerm.create(
      text: '01.03.2015',
      left: 591,
      right: 798,
      top: 773,
      bottom: 809
    )

    DateTerm.create(
      text: '31.03.2015',
      left: 832,
      right: 1038,
      top: 773,
      bottom: 809
    )

    term = create(
      :word,
      text: '-',
      left: 809,
      right: 819,
      top: 794,
      bottom: 797
    )

    result = DateTerm.right_before(term)
    expect(result).to eq previous_term
  end

  it 'can detect the term after another term' do
    DateTerm.create(
      text: '10.04.2015',
      left: 2194,
      right: 2397,
      top: 213,
      bottom: 248
    )

    DateTerm.create(
      text: '15.04.2015',
      left: 2194,
      right: 2397,
      top: 274,
      bottom: 309
    )

    DateTerm.create(
      text: '01.03.2015',
      left: 591,
      right: 798,
      top: 773,
      bottom: 809
    )

    following_term = DateTerm.create(
      text: '31.03.2015',
      left: 832,
      right: 1038,
      top: 773,
      bottom: 809
    )

    term = create(
      :word,
      text: '-',
      left: 809,
      right: 819,
      top: 794,
      bottom: 797
    )

    result = DateTerm.right_after(term)
    expect(result).to eq following_term
  end

  it 'does not detect a term very far to the right of the current term' do
    DateTerm.create(
      text: '15.04.2015',
      left: 2194,
      right: 2397,
      top: 274,
      bottom: 309
    )

    term = create(
      :word,
      text: '-',
      left: 809,
      right: 819,
      top: 794,
      bottom: 797
    )

    result = DateTerm.right_after(term)
    expect(result).to eq nil
  end

  it 'can detect a word right after another on the same line' do
    # From BYnCDzw7nNMFergRW.pdf

    first_word = create(
      :word,
      text: 'Herzlichen',
      left: 2,
      right: 197,
      top: 2223,
      bottom: 2256
    )

    following_word = create(
      :word,
      text: 'Dank',
      left: 215,
      right: 310,
      top: 2223,
      bottom: 2256
    )

    result = Word.right_after(first_word)
    expect(result).to eq following_word
  end

  it 'can detect a word right after another, slightly below' do
    # From BYnCDzw7nNMFergRW.pdf

    first_word = create(
      :word,
      text: 'Michael',
      left: 170,
      right: 310,
      top: 2397,
      bottom: 2430
    )


    following_word = create(
      :word,
      text: 'Augsten',
      left: 326,
      right: 479,
      top: 2397,
      bottom: 2439
    )

    result = Word.right_after(first_word)
    expect(result).to eq following_word
  end
end
