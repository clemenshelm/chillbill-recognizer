# frozen_string_literal: true
require_relative '../../lib/detectors/relative_word_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe RelativeWordDetector do
  it 'detects the relative word prompt' do
    # From ZqMX24iDMxxst5cnP.pdf
    create(
      :word,
      text: 'Zahlungsziel:',
      left: 0.0003333333333333333,
      right: 0.09666666666666666,
      top: 0.5762073027090695,
      bottom: 0.5872791519434629
    )

    create(
      :word,
      text: 'prompt',
      left: 0.11866666666666667,
      right: 0.16933333333333334,
      top: 0.5769140164899882,
      bottom: 0.5872791519434629
    )

    create(
      :word,
      text: '-',
      left: 0.17466666666666666,
      right: 0.179,
      top: 0.5809187279151944,
      bottom: 0.5820965842167256
    )

    relative_words = RelativeWordDetector.filter
    expect(relative_words.map(&:to_s)).to eq ['prompt']
  end
end
