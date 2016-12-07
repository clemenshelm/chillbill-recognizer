# frozen_string_literal: true
require_relative '../../lib/boot'

describe RelativeWordTerm do
  it 'detects a relative word correctly' do
    term = RelativeWordTerm.new(
      text: 'prompt',
      left: 0.11866666666666667,
      right: 0.16933333333333334,
      top: 0.5769140164899882,
      bottom: 0.5872791519434629
    )
    
    expect(term.to_s).to eq 'prompt'
  end
end
