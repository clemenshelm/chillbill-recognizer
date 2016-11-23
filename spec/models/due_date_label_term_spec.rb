# frozen_string_literal: true
require_relative '../../lib/boot'

describe DueDateLabelTerm do
  it 'detects a due date label correctly' do
    term = DueDateLabelTerm.new(
      text: 'Zahlungstermin',
      left: 0.5193333333333333,
      right: 0.613,
      top: 0.0645617342130066,
      bottom: 0.07469368520263903
    )
    expect(term.to_s).to eq 'Zahlungstermin'
  end
end
