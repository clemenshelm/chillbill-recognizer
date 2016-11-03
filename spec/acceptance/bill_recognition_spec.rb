# frozen_string_literal: true
require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do
  it 'recognizes the bill ymX6CL8ssqDsF2WJv' do
    retriever = SpecCacheRetriever.new(file_basename: 'ymX6CL8ssqDsF2WJv.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{ total: 4799, vatRate: 0 }]
    expect(bill_attributes[:invoiceDate]).to eq '2016-08-13'
    expect(bill_attributes[:vatNumber]).to eq 'IE6364992H'
    # expect(bill_attributes[:iban]).to eq ''
    # There is no IBAN number
  end
end
