require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do
  it 'recognizes the bill m6jLaPhmWvuZZqSXy', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'm6jLaPhmWvuZZqSXy')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 4685, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-04'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU17008805'
  end

  it 'recognizes the bill H9WCDhBHp2N7xRLoA' do
    pending "doesn't recognize total value 7,78"
    retriever = SpecCacheRetriever.new(bill_id: 'H9WCDhBHp2N7xRLoA')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 7780, vatRate: 20}]
    # expect(bill_attributes[:vatNumber]).to eq 'ATU18125703'
  end

  it 'recognizes the bill 8r74b2CqZpW5c8oev' do
    pending('one of the prices is being read as the total and vat not found')
    retriever = SpecCacheRetriever.new(bill_id: '8r74b2CqZpW5c8oev')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 5400, vatRate: 20}]
    # expect(bill_attributes[:vatNumber]).to eq 'ATU52569000'
  end

  it 'recognizes the bill 4f5mhL6zBb3cyny7n' do
    pending("Uses 5,41 as net amount instead of 15,41")

    retriever = SpecCacheRetriever.new(bill_id: '4f5mhL6zBb3cyny7n')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1541, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-01'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU16250401'
  end

  it 'recognizes the bill Y8YpKWEJZFunbMymh' do
    pending("The bill is a vertical payment form. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: 'Y8YpKWEJZFunbMymh')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 3600, vatRate: 0}]
    # No VAT Number
  end

  it 'recognizes the bill ZkPkwYF8p6PPLbf7f', :afocus do
    pending('bill time period is being recognized as invoice date')
    retriever = SpecCacheRetriever.new(bill_id: 'ZkPkwYF8p6PPLbf7f')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 9487, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-10'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU45011703'
  end

  it 'recognizes the bill 4WaHezqC7H7HgDzcy' do
    retriever = SpecCacheRetriever.new(bill_id: '4WaHezqC7H7HgDzcy')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 8000, vatRate: 0}]
    # No VAT Number
  end

  it 'recognizes the bill Ghy3MB6y9HeZg2iZB' do
    pending "Total amount of 350,00 is not recognized in payment form"
    retriever = SpecCacheRetriever.new(bill_id: 'Ghy3MB6y9HeZg2iZB')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 35000, vatRate: 0}]
    # No VAT Number
  end

  it 'recognizes the bill dXNmKuRyhwYeNQjbb', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'dXNmKuRyhwYeNQjbb')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 2734, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-03'
    # No VAT Number
  end

  it 'recognizes the bill JRTan9t5Fuo7qE3y4' do
    pending("The bill has a price element that looks very much like a VAT.")
    retriever = SpecCacheRetriever.new(bill_id: 'JRTan9t5Fuo7qE3y4')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 7482, vatRate: 0}]
    # expect(bill_attributes[:vatNumber]).to eq 'ATU40495807'
  end

  it 'recognizes the bill aMajbm6LRwoy96xWa', :afocus do
    # TODO: This bill contains 20% and 10% VAT. This is not important for now,
    # but should be recognized in the future.
    # Another bill with this feature is q475zZuQaP8mmnpt8
    retriever = SpecCacheRetriever.new(bill_id: 'aMajbm6LRwoy96xWa')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 2052, vatRate: 14}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-13'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU37893801'
  end

  it 'recognizes the bill XYt8oerHesxQkdwvp', :afocus do
    pending('the 8 at the end of the total is being misread as 0')
    retriever = SpecCacheRetriever.new(bill_id: 'XYt8oerHesxQkdwvp')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1028, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-10'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU37893801'
  end

  it 'recognizes the bill uFJgmRgy68s3LXzzL', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'uFJgmRgy68s3LXzzL')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 12842, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-13'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU14464300'
  end

  it 'recognizes the bill F4QSZtMfaZKSuzTE2', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'F4QSZtMfaZKSuzTE2')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 19296, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-23'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU68617133'
  end

  it 'recognizes the bill 7FDFZnmZmfMyxWZtG' do
    pending("The bill has prices without decimal places. Make this work as well.")
    retriever = SpecCacheRetriever.new(bill_id: '7FDFZnmZmfMyxWZtG')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1028, vatRate: 0}]
    # More than one VAT ID on doc
  end

  it 'recognizes the bill d8TPPMpm74BmyDsoT' do
    pending("The net amount and VAT amount aren't recognized correctly")
    retriever = SpecCacheRetriever.new(bill_id: 'd8TPPMpm74BmyDsoT')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 114364, vatRate: 20}]
    # expect(bill_attributes[:vatNumber]).to eq 'ATU14464300'
  end

  it 'recognizes the bill pnqSyhfmwa5Qbbmwp' do
    pending('This invoice only contains 10% and 20% VAT, but no total VAT and net amount.')
    retriever = SpecCacheRetriever.new(bill_id: 'pnqSyhfmwa5Qbbmwp')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 41299, vatRate: 19}]
    # expect(bill_attributes[:vatNumber]).to eq 'ATU58058103'
  end

  it 'recognizes the bill YaCWsCoSEuJAr5gAZ' do
    pending("Prices are correct, but prepended with an *")
    retriever = SpecCacheRetriever.new(bill_id: 'YaCWsCoSEuJAr5gAZ')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 5915, vatRate: 20}]
    # expect(bill_attributes[:vatNumber]).to eq 'ATU14221901'
  end

  it 'recognizes the bill T26m53KtQ9JrGhb2T', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'T26m53KtQ9JrGhb2T')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 426164, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-02-29'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU70156715'
  end

  it 'recognizes the bill 27zu8ABiEcPTh2ELu', :afocus do
    pending('one of the prices is being read as the total')
    retriever = SpecCacheRetriever.new(bill_id: '27zu8ABiEcPTh2ELu')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 8697, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-09'
    # No VAT Number
  end

  it 'recognizes the bill BYnCDzw7nNMFergRW', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'BYnCDzw7nNMFergRW')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 29674, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU54441803'
  end

  it 'recognizes the bill iyt9vLXuFfJhJKwJ5', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'iyt9vLXuFfJhJKwJ5')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    # TODO: The vatRate should be 10, but we don't recognize vatRates without
    # net amount yet.
    # expect(bill_attributes[:amounts]).to eq [{total: 29674, vatRate: 10}]
    expect(bill_attributes[:amounts]).to eq [{total: 790, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU57399425'
  end

  it 'recognizes the bill zcEkC9vgfcTv7DBwM', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'zcEkC9vgfcTv7DBwM')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 100000, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-11'
    # No VAT Number
  end

  it 'recognizes the bill Etn9rJm4BAa2vnjyq', :afocus do
    retriever = SpecCacheRetriever.new(bill_id: 'Etn9rJm4BAa2vnjyq')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 323, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-01'
    # expect(bill_attributes[:vatNumber]).to eq 'ATU41472107'
  end
end
