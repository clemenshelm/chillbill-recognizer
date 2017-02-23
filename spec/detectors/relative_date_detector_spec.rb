# frozen_string_literal: true
require_relative '../../lib/detectors/relative_date_detector'
require_relative '../support/factory_girl'
require_relative '../factories'

describe RelativeDateDetector do
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

    relative_words = RelativeDateDetector.filter
    expect(relative_words.map(&:to_s)).to eq ['prompt']
  end

  it 'detects the relative word Fällig bei Erhalt' do
    # From bill 5wsQ7YppaZLN5FSGC.pdf

    create(
      :word,
      text: 'Fällig',
      left: 0.0032722513089005235,
      right: 0.04155759162303665,
      top: 0.8180142824234048,
      bottom: 0.8295323658143285
    )

    create(
      :word,
      text: 'bei',
      left: 0.04744764397905759,
      right: 0.08180628272251309,
      top: 0.8177839207555863,
      bottom: 0.8269983874683253
    )

    create(
      :word,
      text: 'Erhalt',
      left: 0.08900523560209424,
      right: 0.13448952879581152,
      top: 0.8177839207555863,
      bottom: 0.8306841741534209
    )

    relative_words = RelativeDateDetector.filter
    expect(relative_words.map(&:to_s)).to eq ['Fällig bei Erhalt']
  end

  it 'detects the relative word Fällig nach Erhalt' do
    # From ZqMX24iDMxxst5cnP.pdf
    create(
      :word,
      text: 'Fällig',
      left: 0.0032722513089005235,
      right: 0.04155759162303665,
      top: 0.8180142824234048,
      bottom: 0.8295323658143285
    )

    create(
      :word,
      text: 'nach',
      left: 0.04744764397905759,
      right: 0.08180628272251309,
      top: 0.8177839207555863,
      bottom: 0.8269983874683253
    )

    create(
      :word,
      text: 'Erhalt',
      left: 0.08900523560209424,
      right: 0.13448952879581152,
      top: 0.8177839207555863,
      bottom: 0.8306841741534209
    )

    relative_words = RelativeDateDetector.filter
    expect(relative_words.map(&:to_s)).to eq ['Fällig nach Erhalt']
  end
end
