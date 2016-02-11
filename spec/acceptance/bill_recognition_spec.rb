require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do
  it 'recognizes the bill m6jLaPhmWvuZZqSXy' do
    retriever = SpecCacheRetriever.new(bill_id: 'm6jLaPhmWvuZZqSXy')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '39.04'
    expect(bill_attributes[:vatTotal]).to eq '7.81'
  end

  it 'recognizes the bill H9WCDhBHp2N7xRLoA' do
    pending "doesn't recognize total value 7,78"
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
    pending("Doesn't work on CI because of different library versions") if ENV['CI']

    retriever = SpecCacheRetriever.new(bill_id: '4f5mhL6zBb3cyny7n')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '15.41'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
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
    retriever = SpecCacheRetriever.new(bill_id: 'ZkPkwYF8p6PPLbf7f')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '79.06'
    expect(bill_attributes[:vatTotal]).to eq '15.81'
  end 

  it 'recognizes the bill 4WaHezqC7H7HgDzcy' do
    retriever = SpecCacheRetriever.new(bill_id: '4WaHezqC7H7HgDzcy')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '80.00'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill Ghy3MB6y9HeZg2iZB' do
    pending "Total amount of 350,00 is not recognized in payment form"
    retriever = SpecCacheRetriever.new(bill_id: 'Ghy3MB6y9HeZg2iZB')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '350.00'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill dXNmKuRyhwYeNQjbb' do
    retriever = SpecCacheRetriever.new(bill_id: 'dXNmKuRyhwYeNQjbb')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '27.34'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill JRTan9t5Fuo7qE3y4' do
    pending("The bill has a price element that looks very much like a VAT.")
    retriever = SpecCacheRetriever.new(bill_id: 'JRTan9t5Fuo7qE3y4')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '74.82'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill aMajbm6LRwoy96xWa' do
    # TODO: This bill contains 20% and 10% VAT. This is not important for now,
    # but should be recognized in the future.
    # Another bill with this feature is q475zZuQaP8mmnpt8
    retriever = SpecCacheRetriever.new(bill_id: 'aMajbm6LRwoy96xWa')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '17.96'
    expect(bill_attributes[:vatTotal]).to eq '2.56'
  end 

  it 'recognizes the bill XYt8oerHesxQkdwvp' do
    retriever = SpecCacheRetriever.new(bill_id: 'XYt8oerHesxQkdwvp')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '10.28'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill uFJgmRgy68s3LXzzL' do
    retriever = SpecCacheRetriever.new(bill_id: 'uFJgmRgy68s3LXzzL')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '107.02'
    expect(bill_attributes[:vatTotal]).to eq '21.40'
  end 

  it 'recognizes the bill F4QSZtMfaZKSuzTE2' do
    retriever = SpecCacheRetriever.new(bill_id: 'F4QSZtMfaZKSuzTE2')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '160.80'
    expect(bill_attributes[:vatTotal]).to eq '32.16'
  end 

  it 'recognizes the bill 7FDFZnmZmfMyxWZtG' do
    pending("The bill has prices without decimal places. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: '7FDFZnmZmfMyxWZtG')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '10.28'
    expect(bill_attributes[:vatTotal]).to eq '0.00'
  end 

  it 'recognizes the bill d8TPPMpm74BmyDsoT' do
    pending("The net amount and VAT amount aren't recognized correctly")
    retriever = SpecCacheRetriever.new(bill_id: 'd8TPPMpm74BmyDsoT')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '953.03'
    expect(bill_attributes[:vatTotal]).to eq '190.61'
  end 

  it 'recognizes the bill pnqSyhfmwa5Qbbmwp' do
    pending('This invoice only contains 10% and 20% VAT, but no total VAT and net amount.')
    retriever = SpecCacheRetriever.new(bill_id: 'pnqSyhfmwa5Qbbmwp')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '345.74'
    expect(bill_attributes[:vatTotal]).to eq '67.25'
  end 

  it 'recognizes the bill YaCWsCoSEuJAr5gAZ' do
    pending("Prices are correct, but prepended with an *")
    retriever = SpecCacheRetriever.new(bill_id: 'YaCWsCoSEuJAr5gAZ')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:subTotal]).to eq '49.29'
    expect(bill_attributes[:vatTotal]).to eq '9.86'
  end 
end
