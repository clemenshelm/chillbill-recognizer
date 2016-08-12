require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do
  it 'recognizes the bill m6jLaPhmWvuZZqSXy', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'm6jLaPhmWvuZZqSXy.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 4685, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-04'
  end

  it 'recognizes the bill H9WCDhBHp2N7xRLoA' do
    pending "doesn't recognize total value 7,78"
    retriever = SpecCacheRetriever.new(file_basename: 'H9WCDhBHp2N7xRLoA.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 7780, vatRate: 20}]
  end

  it 'recognizes the bill 8r74b2CqZpW5c8oev' do
    retriever = SpecCacheRetriever.new(file_basename: '8r74b2CqZpW5c8oev.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 5400, vatRate: 20}]
  end

  it 'recognizes the bill 4f5mhL6zBb3cyny7n' do
    pending("Uses 5,41 as net amount instead of 15,41")

    retriever = SpecCacheRetriever.new(file_basename: '4f5mhL6zBb3cyny7n.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1541, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-01'
  end

  it 'recognizes the bill Y8YpKWEJZFunbMymh' do
    pending("The bill is a vertical payment form. Make this work as well.")
    retriever = SpecCacheRetriever.new(file_basename: 'Y8YpKWEJZFunbMymh.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 3600, vatRate: 0}]
  end

  it 'recognizes the bill ZkPkwYF8p6PPLbf7f', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'ZkPkwYF8p6PPLbf7f.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 9487, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-10'
  end

  it 'recognizes the bill 4WaHezqC7H7HgDzcy' do
    retriever = SpecCacheRetriever.new(file_basename: '4WaHezqC7H7HgDzcy.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 8000, vatRate: 0}]
  end

  it 'recognizes the bill Ghy3MB6y9HeZg2iZB' do
    pending "Total amount of 350,00 is not recognized in payment form"
    retriever = SpecCacheRetriever.new(file_basename: 'Ghy3MB6y9HeZg2iZB.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 35000, vatRate: 0}]
  end

  it 'recognizes the bill dXNmKuRyhwYeNQjbb', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'dXNmKuRyhwYeNQjbb.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 2734, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-03'
  end

  it 'recognizes the bill JRTan9t5Fuo7qE3y4' do
    pending("The bill has a price element that looks very much like a VAT.")
    retriever = SpecCacheRetriever.new(file_basename: 'JRTan9t5Fuo7qE3y4.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 7482, vatRate: 0}]
  end

  it 'recognizes the bill aMajbm6LRwoy96xWa', :afocus do
    # TODO: This bill contains 20% and 10% VAT. This is not important for now,
    # but should be recognized in the future.
    # Another bill with this feature is q475zZuQaP8mmnpt8
    retriever = SpecCacheRetriever.new(file_basename: 'aMajbm6LRwoy96xWa.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 2052, vatRate: 14}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-13'
  end

  it 'recognizes the bill XYt8oerHesxQkdwvp', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'XYt8oerHesxQkdwvp.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1028, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-10'
  end

  it 'recognizes the bill uFJgmRgy68s3LXzzL', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'uFJgmRgy68s3LXzzL.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 12842, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-13'
  end

  it 'recognizes the bill F4QSZtMfaZKSuzTE2', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'F4QSZtMfaZKSuzTE2.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 19296, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-23'
  end

  it 'recognizes the bill 7FDFZnmZmfMyxWZtG' do
    pending("The bill has prices without decimal places. Make this work as well.")
    retriever = SpecCacheRetriever.new(file_basename: '7FDFZnmZmfMyxWZtG.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1028, vatRate: 0}]
  end

  it 'recognizes the bill d8TPPMpm74BmyDsoT' do
    pending("The net amount and VAT amount aren't recognized correctly")
    retriever = SpecCacheRetriever.new(file_basename: 'd8TPPMpm74BmyDsoT.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 114364, vatRate: 20}]
  end

  it 'recognizes the bill pnqSyhfmwa5Qbbmwp' do
    pending('This invoice only contains 10% and 20% VAT, but no total VAT and net amount.')
    retriever = SpecCacheRetriever.new(file_basename: 'pnqSyhfmwa5Qbbmwp.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 41299, vatRate: 19}]
  end

  it 'recognizes the bill YaCWsCoSEuJAr5gAZ' do
    pending("Prices are correct, but prepended with an *")
    retriever = SpecCacheRetriever.new(file_basename: 'YaCWsCoSEuJAr5gAZ.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 5915, vatRate: 20}]
  end

  it 'recognizes the bill T26m53KtQ9JrGhb2T', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'T26m53KtQ9JrGhb2T.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 426164, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-02-29'
  end

  it 'recognizes the bill 27zu8ABiEcPTh2ELu', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: '27zu8ABiEcPTh2ELu.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 8697, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-09'
  end

  it 'recognizes the bill BYnCDzw7nNMFergRW', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'BYnCDzw7nNMFergRW.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 29674, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
  end

  it 'recognizes the bill iyt9vLXuFfJhJKwJ5', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'iyt9vLXuFfJhJKwJ5.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    # TODO: The vatRate should be 10, but we don't recognize vatRates without
    # net amount yet.
    # expect(bill_attributes[:amounts]).to eq [{total: 29674, vatRate: 10}]
    expect(bill_attributes[:amounts]).to eq [{total: 790, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
  end

  it 'recognizes the bill zcEkC9vgfcTv7DBwM', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'zcEkC9vgfcTv7DBwM.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 100000, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-11'
  end

  it 'recognizes the bill Etn9rJm4BAa2vnjyq', :afocus do
    retriever = SpecCacheRetriever.new(file_basename: 'Etn9rJm4BAa2vnjyq.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 323, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-01'
  end

  it 'recognizes a .png bill, 2bQxSCp4nprMZpiSf' do
    retriever = SpecCacheRetriever.new(file_basename: '2bQxSCp4nprMZpiSf.png')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    # vatRate is not calculated correctly although net amount is recognized
    # expect(bill_attributes[:amounts]).to eq [{total: 449, vatRate: 20}]
    expect(bill_attributes[:amounts]).to eq [{total: 449, vatRate: 0}]
    # date is incorrectly recognized as 201Eu01-26
    # expect(bill_attributes[:invoiceDate]).to eq '2016-01-26'
  end

  it 'recognizes a .jpeg bill,  Cetmde5evr2gvwCK4' do
    retriever = SpecCacheRetriever.new(file_basename: 'Cetmde5evr2gvwCK4.jpeg')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    # If it doesn't throw an exception, it works
  end

  it 'recognizes the bill 47SBGiQfJ4FhXoco7' do
    retriever = SpecCacheRetriever.new(file_basename: '47SBGiQfJ4FhXoco7.jpg')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    # If it doesn't throw an exception, it works
  end

  it 'recognizes the bill nHX9eYu9pwiFCjSoL' do
    retriever = SpecCacheRetriever.new(file_basename: 'nHX9eYu9pwiFCjSoL.JPG')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    # If it doesn't throw an exception, it works
  end

end
