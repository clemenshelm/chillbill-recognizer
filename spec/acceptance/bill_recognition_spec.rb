# frozen_string_literal: true
require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do
  it 'recognizes the bill BYnCDzw7nNMFergRW' do
    retriever = SpecCacheRetriever.new(file_basename: 'fGHCBxN6cbksNrHpo.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    # expect(bill_attributes[:amounts]).to eq [{ total: 29_674, vatRate: 20 }]
    # expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU54441803'
    # expect(bill_attributes[:iban]).to eq 'AT431200010626827900'
    expect(bill_attributes[:dueDate]).to eq '2016-10-18'
  end
end
