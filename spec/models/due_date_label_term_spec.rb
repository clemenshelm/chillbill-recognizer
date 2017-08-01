# frozen_string_literal: true
require_relative '../../lib/boot'

describe DueDateLabelTerm do
  it 'detects a due date label correctly' do
    term = DueDateLabelTerm.new(
      text: 'Zahlungstermin',
      left: 0.59633627739614,
      right: 0.6892378148511613,
      top: 0.22600046264168402,
      bottom: 0.2359472588480222
    )
    expect(term.to_s).to eq 'Zahlungstermin'
  end
end
