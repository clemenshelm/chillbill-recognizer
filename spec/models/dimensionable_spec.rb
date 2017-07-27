# frozen_string_literal: true
require_relative '../support/factory_girl'
require_relative '../factories'

describe Dimensionable do
  before(:each) do
    # A4 format as default
    BillDimension.create_all(width: 3057, height: 4323)
  end

  it 'can detect the width of a term' do
    # From BYnCDzw7nNMFergRW.pdf
    term = DateTerm.new(
      text: '16.03.2016',
      left: 0.68717277486911,
      right: 0.7555628272251309,
      top: 0.16951896392229418,
      bottom: 0.1769195189639223,
      first_word_id: 26
    )

    expect(term.width).to eq 0.06839005235602091
  end

  it 'can detect the height of a term' do
    # From BYnCDzw7nNMFergRW.pdf
    term = DateTerm.new(
      text: '16.03.2016',
      left: 0.68717277486911,
      right: 0.7555628272251309,
      top: 0.16951896392229418,
      bottom: 0.1769195189639223,
      first_word_id: 26
    )

    expect(term.height).to eq 0.007400555041628121
  end

  describe '#right_before' do
    it 'can detect the term before another term' do
      # Missing label - needs terms one before the other
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

    it 'does not consider items on another line' do
      # From 3EagyvJYF2RJhNTQC.pdf
      create(
        :word,
        text: '01.06.2016',
        left: 0.1400523560209424,
        right: 0.22971204188481675,
        top: 0.30411655874190563,
        bottom: 0.31290471785383905
      )

      word_on_other_line = create(
        :word,
        text: 'Preis',
        left: 0.8821989528795812,
        right: 0.9204842931937173,
        top: 0.3526827012025902,
        bottom: 0.3621646623496762
      )

      result = Word.right_before(word_on_other_line)
      expect(result).to be_nil
    end
  end

  describe '#right_after' do
    it 'can detect the term after another term' do
      # Missing label - needs terms one after the other
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

    it 'detects a term further away' do
      # Missing label - needs terms one after the other further away
      label = DueDateLabelTerm.create(
        text: 'Zahlungstermin',
        left: 0.5700261780104712,
        right: 0.6659031413612565,
        top: 0.2837650323774283,
        bottom: 0.2937095282146161
      )

      date = DateTerm.create(
        text: '22.11.2016',
        left: 0.8125,
        right: 0.8524214659685864,
        top: 0.2835337650323774,
        bottom: 0.29162812210915817
      )

      following_term = DateTerm.right_after(label)
      expect(following_term).to eq date
    end

    it 'does not detect a term very far to the right of the current term' do
      # Missing label - needs terms very far from another
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
        left: 0.08147905759162304,
        right: 0.1462696335078534,
        top: 0.57631822386679,
        bottom: 0.5837187789084182
      )

      following_word = create(
        :word,
        text: 'Dank',
        left: 0.15248691099476439,
        right: 0.18390052356020942,
        top: 0.57631822386679,
        bottom: 0.5837187789084182
      )

      result = Word.right_after(first_word)
      expect(result).to eq following_word
    end

    it 'can detect a word right after another, slightly below' do
      # From BYnCDzw7nNMFergRW.pdf
      first_word = create(
        :word,
        text: 'Michael',
        left: 0.13710732984293195,
        right: 0.18390052356020942,
        top: 0.6172525439407955,
        bottom: 0.6246530989824237
      )

      following_word = create(
        :word,
        text: 'Augsten',
        left: 0.18913612565445026,
        right: 0.23985602094240838,
        top: 0.6172525439407955,
        bottom: 0.6265032377428307
      )

      result = Word.right_after(first_word)
      expect(result).to eq following_word
    end
  end

  describe '#below' do
    it 'detects a word on a line further down the page' do
      # From xAkCJuSGM8A4ZGoSy.pdf
      first_word = create(
        :word,
        text: 'Zahlungstermin',
        left: 0.79816813869807,
        right: 0.8920510304219823,
        top: 0.3395789960675457,
        bottom: 0.34883182974786026
      )

      following_word = create(
        :word,
        text: '2016.12.09.',
        left: 0.8060189728491985,
        right: 0.8842001962708538,
        top: 0.3624797594263243,
        bottom: 0.3708073097386074
      )

      result = Word.below(first_word)
      expect(result).to eq following_word
    end

    it 'does not detect a word shifted horizontally' do
      # From xAkCJuSGM8A4ZGoSy.pdf
      first_word = create(
        :word,
        text: 'Zahlungstermin',
        left: 0.79816813869807,
        right: 0.8920510304219823,
        top: 0.3395789960675457,
        bottom: 0.34883182974786026
      )

      create(
        :word,
        text: '2016.11.23.',
        left: 0.6300294406280668,
        right: 0.708210664049722,
        top: 0.36294240111034004,
        bottom: 0.3710386305806153
      )

      result = Word.below(first_word)
      expect(result).to be_nil
    end
  end

  describe '#right_below' do
    it 'detects a word directly below another' do
      # From Z6vrodr97FEZXXotA.pdf
      first_word = create(
        :word,
        text: 'Rechnungsnummer',
        left: 0.28720968269545305,
        right: 0.4435721295387635,
        top: 0.06916493176035161,
        bottom: 0.08026833217672913
      )

      word_below = create(
        :word,
        text: '6117223355',
        left: 0.28655544651619236,
        right: 0.3784756297023225,
        top: 0.08350682396483923,
        bottom: 0.09206569511913024
      )

      result = Word.right_below(first_word)
      expect(result).to eq word_below
    end
  end
end
