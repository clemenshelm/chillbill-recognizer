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

  describe '#right_before' do
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

    it 'does not consider items on another line' do
      # From 3EagyvJYF2RJhNTQC.pdf
      create(
        :word,
        text: '01.06.2016',
        left: 0.07395287958115183,
        right: 0.16393979057591623,
        top: 0.22664199814986125,
        bottom: 0.23566142460684553
      )

      hyphen = create(
        :word,
        text: '-',
        left: 0.18259162303664922,
        right: 0.18848167539267016,
        top: 0.4114246068455134,
        bottom: 0.4128122109158187
      )

      result = Word.right_before(hyphen)
      expect(result).to be_nil
    end
  end

    describe '#right_after' do
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

    it 'detects a term further away' do
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

  describe '#below' do
    it 'detects a word on a line further down the page' do
      # From xAkCJuSGM8A4ZGoSy.pdf
      first_word = create(
        :word,
        text: 'Zahlungstermin',
        left: 0.7877003598298986,
        right: 0.8815832515538109,
        top: 0.2933148276659727,
        bottom: 0.30279898218829515
      )

      following_word = create(
        :word,
        text: '2016.12.09.',
        left: 0.7955511939810271,
        right: 0.8740595354923127,
        top: 0.3164469118667592,
        bottom: 0.3250057830210502
      )

      result = Word.below(first_word)
      expect(result).to eq following_word
    end

    it 'does not detect a word shifted horizontally' do
      # From xAkCJuSGM8A4ZGoSy.pdf
      first_word = create(
        :word,
        text: 'Zahlungstermin',
        left: 0.7877003598298986,
        right: 0.8815832515538109,
        top: 0.2933148276659727,
        bottom: 0.30279898218829515
      )

      create(
        :word,
        text: '2016.11.23.',
        left: 0.6195616617598954,
        right: 0.6977428851815506,
        top: 0.31690955355077494,
        bottom: 0.32523710386305804
      )

      result = Word.below(first_word)
      expect(result).to be_nil
    end
  end

  describe '#right_below' do
    it "detects a word directly below another" do
      # From Z6vrodr97FEZXXotA.pdf
      first_word = create(
        :word,
        text: 'Rechnungsnummer',
        left: 0.1920183186130193,
        right: 0.34838076545632973,
        top: 0.0,
        bottom: 0.011103400416377515
      )

      word_below = create(
        :word,
        text: '6117223355',
        left: 0.19136408243375858,
        right: 0.2832842656198888,
        top: 0.014341892204487625,
        bottom: 0.022900763358778626
      )

      result = Word.right_below(first_word)
      expect(result).to eq word_below
    end
  end
end
