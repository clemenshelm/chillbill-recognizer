# frozen_string_literal: true
require_relative '../../lib/detectors/due_date_label_detector'
require_relative '../support/factory_girl'
require_relative '../factories' # should be loaded automatically

describe DueDateLabelDetector do
  it "detects the due date label 'Zahlungstermin'" do
    # From ZkPkwYF8p6PPLbf7f.png
    create(
      :word,
      text: '44',
      left: 0.2845927379784102,
      right: 0.2989859339221459,
      top: 0.2246125375896368,
      bottom: 0.23247744621790423
    )

    create(
      :word,
      text: 'Zahlungstermin',
      left: 0.59633627739614,
      right: 0.6892378148511613,
      top: 0.22600046264168402,
      bottom: 0.2359472588480222
    )

    create(
      :word,
      text: '15.04.2015',
      left: 0.8079816813869807,
      right: 0.8753680078508341,
      top: 0.22576914179967614,
      bottom: 0.2340966921119593
    )

    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['Zahlungstermin']
  end

  it "detects the due date label 'Zahlungsziel:'" do
    # From fGHCBxN6cbksNrHpo.pdf
    create(
      :word,
      text: 'Zahlungsziel:',
      left: 0.7085377821393523,
      right: 0.8056918547595682,
      top: 0.32130464954892435,
      bottom: 0.3324080499653019
    )

    create(
      :word,
      text: '18.10.2016',
      left: 0.8132155708210664,
      right: 0.8946679751390252,
      top: 0.32153597039093224,
      bottom: 0.3300948415452232
    )

    create(
      :word,
      text: 'Kunden',
      left: 0.647693817468106,
      right: 0.7029767746156362,
      top: 0.33610918343742774,
      bottom: 0.34489937543372656
    )

    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['Zahlungsziel:']
  end

  it "detects the due date label 'Due Date:'" do
    # From 7FDFZnmZmfMyxWZtG.pdf
    create(
      :word,
      text: 'Due',
      left: 0.12303664921465969,
      right: 0.15346858638743455,
      top: 0.4424144310823312,
      bottom: 0.45120259019426456
    )

    create(
      :word,
      text: 'Date:',
      left: 0.1606675392670157,
      right: 0.20157068062827224,
      top: 0.4424144310823312,
      bottom: 0.45120259019426456
    )

    create(
      :word,
      text: 'Invoice',
      left: 0.5317408376963351,
      right: 0.588023560209424,
      top: 0.4421831637372803,
      bottom: 0.45120259019426456
    )

    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['Due Date:']
  end

  it 'detects the due date label Fällig' do
    # From BYnCDzw7nNMFergRW.pdf
    create(
      :word,
      text: 'Fällig',
      left: 0.6259816753926701,
      right: 0.6577225130890052,
      top: 0.19033302497687327,
      bottom: 0.19958371877890843
    )

    create(
      :word,
      text: '21.03.2016',
      left: 0.6861910994764397,
      right: 0.7555628272251309,
      top: 0.19033302497687327,
      bottom: 0.1977335800185014
    )

    create(
      :word,
      text: 'Rechnung',
      left: 0.08147905759162304,
      right: 0.143651832460733,
      top: 0.22964847363552265,
      bottom: 0.23889916743755782
    )

    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['Fällig']
  end

  it 'detects the due date label zahlbar am' do
    # From JBopEY4wukRCb7Sjh.pdf
    create(
      :word,
      text: 'zahlbar',
      left: 0.28304973821989526,
      right: 0.32591623036649214,
      top: 0.2192613370733988,
      bottom: 0.22580645161290322
    )

    create(
      :word,
      text: 'am',
      left: 0.33017015706806285,
      right: 0.3458769633507853,
      top: 0.22136512388966806,
      bottom: 0.22580645161290322
    )

    create(
      :word,
      text: '29.',
      left: 0.42277486910994766,
      right: 0.4397905759162304,
      top: 0.21996259934548854,
      bottom: 0.2260402057035998
    )

    create(
      :word,
      text: 'August',
      left: 0.443717277486911,
      right: 0.48462041884816753,
      top: 0.21972884525479197,
      bottom: 0.22791023842917252
    )

    create(
      :word,
      text: '2016',
      left: 0.4882198952879581,
      right: 0.5160340314136126,
      top: 0.21996259934548854,
      bottom: 0.2260402057035998
    )
    due_date_labels = DueDateLabelDetector.filter
    expect(due_date_labels.map(&:to_s)).to eq ['zahlbar am']
  end

  it 'detects the correct due date label regex' do
    create(
      :word,
      text: 'zahlbar',
      left: 0.28304973821989526,
      right: 0.32591623036649214,
      top: 0.2192613370733988,
      bottom: 0.22580645161290322
    )

    create(
      :word,
      text: 'am',
      left: 0.33017015706806285,
      right: 0.3458769633507853,
      top: 0.22136512388966806,
      bottom: 0.22580645161290322
    )

    create(
      :word,
      text: '29.',
      left: 0.42277486910994766,
      right: 0.4397905759162304,
      top: 0.21996259934548854,
      bottom: 0.2260402057035998
    )

    create(
      :word,
      text: 'August',
      left: 0.443717277486911,
      right: 0.48462041884816753,
      top: 0.21972884525479197,
      bottom: 0.22791023842917252
    )

    create(
      :word,
      text: '2016',
      left: 0.4882198952879581,
      right: 0.5160340314136126,
      top: 0.21996259934548854,
      bottom: 0.2260402057035998
    )

    currencies = DueDateLabelDetector.filter
    expect(currencies.map(&:regex)).to eq [DueDateLabelDetector::DUE_DATE_LABELS.to_s]
  end
end
