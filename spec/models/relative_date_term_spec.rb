# frozen_string_literal: true
require_relative '../../lib/boot'

describe RelativeDateTerm do
  it 'detects a relative word correctly' do
    # From ZqMX24iDMxxst5cnP.pdf
    term = RelativeDateTerm.new(
      text: 'prompt',
      left: 0.21465968586387435,
      right: 0.26472513089005234,
      top: 0.6281221091581869,
      bottom: 0.6382978723404256
    )

    expect(term.to_s).to eq 'prompt'
  end
end
