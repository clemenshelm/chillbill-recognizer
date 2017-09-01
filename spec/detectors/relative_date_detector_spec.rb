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
      left: 0.09620418848167539,
      right: 0.19208115183246074,
      top: 0.6274283071230342,
      bottom: 0.6382978723404256
    )

    create(
      :word,
      text: 'prompt',
      left: 0.21465968586387435,
      right: 0.26472513089005234,
      top: 0.6281221091581869,
      bottom: 0.6382978723404256
    )

    create(
      :word,
      text: '-',
      left: 0.27028795811518325,
      right: 0.2742146596858639,
      top: 0.6320536540240518,
      bottom: 0.6329787234042553
    )

    relative_words = RelativeDateDetector.filter
    expect(relative_words.map(&:to_s)).to eq ['prompt']
  end

  it 'detects the relative word Fällig bei Erhalt' do
    # From bill 5wsQ7YppaZLN5FSGC.pdf
    create(
      :word,
      text: 'Fällig',
      left: 0.44030094864245994,
      right: 0.47759241086032056,
      top: 0.301411057136248,
      bottom: 0.31251445755262547
    )

    create(
      :word,
      text: 'nach',
      left: 0.4844618907425581,
      right: 0.5047432122996401,
      top: 0.301411057136248,
      bottom: 0.3102012491325468
    )

    create(
      :word,
      text: 'Erhalt',
      left: 0.511939810271508,
      right: 0.5538109257441937,
      top: 0.301411057136248,
      bottom: 0.3102012491325468
    )

    relative_words = RelativeDateDetector.filter
    expect(relative_words.map(&:to_s)).to eq ['Fällig nach Erhalt']
  end

  it 'detects the relative word Fällig nach Erhalt' do
    # Missing label - needs Fällig bei Erhalt
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

  it 'detects the correct relative word regex' do
    # From 5wsQ7YppaZLN5FSGC.pdf
    create(
      :word,
      text: 'Fällig',
      left: 0.44030094864245994,
      right: 0.47759241086032056,
      top: 0.301411057136248,
      bottom: 0.31251445755262547
    )

    create(
      :word,
      text: 'nach',
      left: 0.4844618907425581,
      right: 0.5047432122996401,
      top: 0.301411057136248,
      bottom: 0.3102012491325468
    )

    create(
      :word,
      text: 'Erhalt',
      left: 0.511939810271508,
      right: 0.5538109257441937,
      top: 0.301411057136248,
      bottom: 0.3102012491325468
    )

    relative_words = RelativeDateDetector.filter
    relative_regex = /#{RelativeDateDetector::ALL_REL_WORDS.map { |s| Regexp.quote(s) }.join('|')}/
    expect(relative_words.map(&:regex)).to eq [relative_regex.to_s]
  end
end
