require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing ChillBill’s bills correctly' do
  it 'recognizes the bill gANywe3fjvx98iPp2' do
    retriever = SpecCacheRetriever.new(file_basename: 'gANywe3fjvx98iPp2.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 799, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-11-19'
  end

  it 'recognizes the bill MM4o4pPK9Ttp2MqvJ', :focus do
    retriever = SpecCacheRetriever.new(file_basename: 'MM4o4pPK9Ttp2MqvJ.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 36000, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-11-23'
  end

  it 'recognizes the bill wrj8fiNZQYjymoocT' do
    retriever = SpecCacheRetriever.new(file_basename: 'wrj8fiNZQYjymoocT.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 800, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-11-30'
  end

  it 'recognizes the bill 7Nvce6pPniK3BCCA7' do
    retriever = SpecCacheRetriever.new(file_basename: '7Nvce6pPniK3BCCA7.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 7507, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-12-04'
  end
end
