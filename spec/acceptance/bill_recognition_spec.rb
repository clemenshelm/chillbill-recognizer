# frozen_string_literal: true
require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'
describe 'Recognizing bills correctly' do
  it 'recognizes the bill BYnCDzw7nNMFergRW' do
    retriever = SpecCacheRetriever.new(file_basename: 'BYnCDzw7nNMFergRW.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{ total: 29_674, vatRate: 20 }]
    expect(bill_attributes[:currencyCode]).to eq 'EUR'
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
    expect(bill_attributes[:dueDate]).to eq '2016-03-21'
    expect(bill_attributes[:vatNumber]).to eq 'ATU54441803'
    expect(bill_attributes[:iban]).to eq 'AT431200010626827900'
    expect(bill_attributes[:clockwiseRotationsRequired]).to eq 0
    expect(bill_attributes[:qrCodePresent]).to be false
    expect(bill_attributes[:invoiceNumber]).to be_nil
  end

  it 'recognizes a bill with QR code' do
    retriever = SpecCacheRetriever.new(file_basename: 'pYbaWiFCmR7rbhx9K.png')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:qrCodePresent]).to be true
    expect(bill_attributes[:amounts]).to eq [{ total: 5_90, vatRate: 10 }]
    expect(bill_attributes[:dueDate]).to eq '2017-06-13'
    expect(bill_attributes[:invoiceDate]).to eq '2017-06-13'
    expect(bill_attributes[:vatNumber]).to eq 'ATU69210837'
    expect(bill_attributes[:currencyCode]).to eq 'EUR'
  end
end
