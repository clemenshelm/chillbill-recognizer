# frozen_string_literal: true
require_relative '../support/factory_girl'
require_relative '../factories'

describe Dimensionable do
  before(:each) do
    # A4 format as default
    BillDimension.create_image_dimensions(width: 3057, height: 4323)
  end

  it 'can calculate the width of a term' do
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

  it 'can calculate the height of a term' do
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

  it 'can calculate the horizontal_center of a term' do
    # From BYnCDzw7nNMFergRW.pdf
    term = DateTerm.new(
      text: '16.03.2016',
      left: 0.68717277486911,
      right: 0.7555628272251309,
      top: 0.16951896392229418,
      bottom: 0.1769195189639223,
      first_word_id: 26
    )

    expect(term.horizontal_center).to eq 0.7213678010471205
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

    it 'does not detect a word above another' do
      # From WmcA2uThGP5QaaciP.pdf
      create(
        :word,
        text: 'kg',
        left: 0.7480366492146597,
        right: 0.7673429319371727,
        top: 0.3856845031271717,
        bottom: 0.39587676627287466
      )

      below = create(
        :word,
        text: '123,00',
        left: 0.7081151832460733,
        right: 0.7653795811518325,
        top: 0.41463979615473706,
        bottom: 0.4232105628908965
      )

      result = Word.right_below(below)
      expect(result).to be_nil
    end
  end

  describe '#in_same_column' do
    it 'detects a words in the same column' do
      # From ZqMX24iDMxxst5cnP.pdf
      word1 = create(
        :word,
        text: 'Ristretto',
        left: 0.2087696335078534,
        right: 0.26767015706806285,
        top: 0.3808973172987974,
        bottom: 0.3894542090656799
      )

      create(
        :word,
        text: 'Livanto',
        left: 0.20844240837696335,
        right: 0.2594895287958115,
        top: 0.4024051803885291,
        bottom: 0.41096207215541164
      )

      word2 = create(
        :word,
        text: 'Caramelito',
        left: 0.2081151832460733,
        right: 0.2859947643979058,
        top: 0.44472710453284,
        bottom: 0.45351526364477335
      )

      result = Word.send(:in_same_column, word1, word2)
      expect(result).to eq true
    end
  end

  describe '#right_above' do
    it 'detects a word directly above another' do
      # From WmcA2uThGP5QaaciP.pdf
      create(
        :word,
        text: 'GmbH',
        left: 0.2012434554973822,
        right: 0.24149214659685864,
        top: 0.08617095205003475,
        bottom: 0.09427843409775306
      )

      create(
        :word,
        text: 'Telefon',
        left: 0.5163612565445026,
        right: 0.5863874345549738,
        top: 0.08617095205003475,
        bottom: 0.09427843409775306
      )

      create(
        :word,
        text: ':',
        left: 0.6914267015706806,
        right: 0.694371727748691,
        top: 0.08941394486912208,
        bottom: 0.09427843409775306
      )

      above = create(
        :word,
        text: 'kg',
        left: 0.7480366492146597,
        right: 0.7673429319371727,
        top: 0.3856845031271717,
        bottom: 0.39587676627287466
      )

      below = create(
        :word,
        text: '123,00',
        left: 0.7081151832460733,
        right: 0.7653795811518325,
        top: 0.41463979615473706,
        bottom: 0.4232105628908965
      )

      result = Word.right_above(below)
      expect(result).to eq above
    end
  end

  describe '#on_same_line' do
    it 'detects if a word is on the same line' do
      # From ZqMX24iDMxxst5cnP.pdf
      word1 = create(
        :word,
        text: 'Ristretto',
        left: 0.2087696335078534,
        right: 0.26767015706806285,
        top: 0.3808973172987974,
        bottom: 0.3894542090656799
      )

      word2 = create(
        :word,
        text: 'Kaffee',
        left: 0.2846858638743455,
        right: 0.33049738219895286,
        top: 0.38066604995374653,
        bottom: 0.3894542090656799
      )

      result = Word.send(:on_same_line, word1, word2)
      expect(result).to eq true
    end
  end
end
