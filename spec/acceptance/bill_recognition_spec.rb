require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do
  it 'recognizes the bill m6jLaPhmWvuZZqSXy' do
    pending("Doesn't work on CI because of different library versions") if ENV['CI']

    retriever = SpecCacheRetriever.new(bill_id: 'm6jLaPhmWvuZZqSXy')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '39.04'
    expect(bill_attributes[:vatTotal]).to eq '7.81'
  end

  it 'recognizes the bill H9WCDhBHp2N7xRLoA' do
    pending("Doesn't work on CI because of different library versions") if ENV['CI']

    retriever = SpecCacheRetriever.new(bill_id: 'H9WCDhBHp2N7xRLoA')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '6.48'
    expect(bill_attributes[:vatTotal]).to eq '1.30'
  end

  it 'recognizes the bill 8r74b2CqZpW5c8oev' do
    retriever = SpecCacheRetriever.new(bill_id: '8r74b2CqZpW5c8oev')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '45.00'
    expect(bill_attributes[:vatTotal]).to eq '9.00'
  end

  it 'recognizes the bill 4f5mhL6zBb3cyny7n' do
    retriever = SpecCacheRetriever.new(bill_id: '4f5mhL6zBb3cyny7n')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '15.41'
    expect(bill_attributes[:vatTotal]).to eq '0'
  end

  it 'recognizes the bill Y8YpKWEJZFunbMymh' do
    pending("The bill is a vertical payment form. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: 'Y8YpKWEJZFunbMymh')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '36'
    expect(bill_attributes[:vatTotal]).to eq '0'
  end 

  it 'recognizes the bill ZkPkwYF8p6PPLbf7f' do
    pending("The bill has a transparent background which OpenCv sees as black. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: 'ZkPkwYF8p6PPLbf7f')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '79.06'
    expect(bill_attributes[:vatTotal]).to eq '15.81'
  end 

  it 'recognizes the bill ZkPkwYF8p6PPLbf7f' do
    pending("The bill has a vat of 0, so net amount equals total amount. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: 'ZkPkwYF8p6PPLbf7f')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '80.00'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill Ghy3MB6y9HeZg2iZB' do
    pending("The bill has no vat, so net amount equals total amount. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: 'ZkPkwYF8p6PPLbf7f')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '350.00'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 
end
