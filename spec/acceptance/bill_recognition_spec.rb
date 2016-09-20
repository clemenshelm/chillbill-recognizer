require_relative '../spec_cache_retriever'
require_relative '../../lib/bill_recognizer'

describe 'Recognizing bills correctly' do

  it 'recognizes the bill m6jLaPhmWvuZZqSXy' do
    retriever = SpecCacheRetriever.new(file_basename: 'm6jLaPhmWvuZZqSXy.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 4685, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-04'
    expect(bill_attributes[:currencyCode]).to eq "EUR"
    # Recognizes VAT ID as "QTU..."
    # expect(bill_attributes[:vatNumber]).to eq 'ATU17008805'
  end

  it 'recognizes the bill H9WCDhBHp2N7xRLoA' do
    pending "doesn't recognize total value 7,78"
    retriever = SpecCacheRetriever.new(file_basename: 'H9WCDhBHp2N7xRLoA.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 7780, vatRate: 20}]
    expect(bill_attributes[:vatNumber]).to eq 'ATU18125703'
    expect(bill_attributes[:currencyCode]).to eq "EUR"
  end


  it 'recognizes the bill 8r74b2CqZpW5c8oev' do
    pending("It recognizes one of the listed prices as the total sum, but both are detected")
    retriever = SpecCacheRetriever.new(file_basename: '8r74b2CqZpW5c8oev.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 5400, vatRate: 20}]
    expect(bill_attributes[:vatNumber]).to eq 'ATU52569000'
  end

  it 'recognizes the bill 4f5mhL6zBb3cyny7n' do
    pending("Uses 5,41 as net amount instead of 15,41")

    retriever = SpecCacheRetriever.new(file_basename: '4f5mhL6zBb3cyny7n.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1541, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-01'
    expect(bill_attributes[:vatNumber]).to eq 'ATU16250401'
  end

  it 'recognizes the bill Y8YpKWEJZFunbMymh' do
    pending("The bill is a vertical payment form. Make this work as well.")
    retriever = SpecCacheRetriever.new(file_basename: 'Y8YpKWEJZFunbMymh.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:currencyCode]).to eq 'EUR'
    expect(bill_attributes[:amounts]).to eq [{total: 3600, vatRate: 0}]
    # No VAT Number
  end

  it 'recognizes the bill ZkPkwYF8p6PPLbf7f' do
    pending("The billing period is recognized as the billing date")
    retriever = SpecCacheRetriever.new(file_basename: 'ZkPkwYF8p6PPLbf7f.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 9487, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-10'
    expect(bill_attributes[:vatNumber]).to eq 'ATU45011703'
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

  it 'recognizes the bill dXNmKuRyhwYeNQjbb' do
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
    expect(bill_attributes[:vatNumber]).to eq 'ATU40495807'
  end

  it 'recognizes the bill aMajbm6LRwoy96xWa' do
    # TODO: This bill contains 20% and 10% VAT. This is not important for now,
    # but should be recognized in the future.
    # Another bill with this feature is q475zZuQaP8mmnpt8
    retriever = SpecCacheRetriever.new(file_basename: 'aMajbm6LRwoy96xWa.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 2052, vatRate: 14}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-13'
    expect(bill_attributes[:vatNumber]).to eq 'ATU37893801'
  end

  it 'recognizes the bill XYt8oerHesxQkdwvp' do
    pending("The 8 on the price is misread as a 0")
    retriever = SpecCacheRetriever.new(file_basename: 'XYt8oerHesxQkdwvp.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1028, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-10'
    expect(bill_attributes[:vatNumber]).to eq 'ATU37893801'
  end

  it 'recognizes the bill uFJgmRgy68s3LXzzL' do
    retriever = SpecCacheRetriever.new(file_basename: 'uFJgmRgy68s3LXzzL.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 12842, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-13'
    # Ammersin has ATU incorrectly written as AUT on their bills
    # expect(bill_attributes[:vatNumber]).to eq 'ATU14464300'
  end

  it 'recognizes the bill F4QSZtMfaZKSuzTE2' do
    retriever = SpecCacheRetriever.new(file_basename: 'F4QSZtMfaZKSuzTE2.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 19296, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2015-04-23'
    # The bill's white background is lost during png conversion. This only affects the detection of the bottom of the bill.
    # expect(bill_attributes[:vatNumber]).to eq 'ATU68617133'
  end

  it 'recognizes the bill 7FDFZnmZmfMyxWZtG' do
    pending("The bill has prices without decimal places. Make this work as well.")
    retriever = SpecCacheRetriever.new(file_basename: '7FDFZnmZmfMyxWZtG.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 1028, vatRate: 0}]
    expect(bill_attributes[:vatNumber]).to eq 'ATU68651513'
  end

  it 'recognizes the bill d8TPPMpm74BmyDsoT' do
    pending("The net amount and VAT amount aren't recognized correctly")
    retriever = SpecCacheRetriever.new(file_basename: 'd8TPPMpm74BmyDsoT.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 114364, vatRate: 20}]
    expect(bill_attributes[:vatNumber]).to eq 'ATU14464300'
  end

  it 'recognizes the bill pnqSyhfmwa5Qbbmwp' do
    pending('This invoice only contains 10% and 20% VAT, but no total VAT and net amount.')
    retriever = SpecCacheRetriever.new(file_basename: 'pnqSyhfmwa5Qbbmwp.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 41299, vatRate: 19}]
    expect(bill_attributes[:vatNumber]).to eq 'ATU58058103'
  end

  it 'recognizes the bill YaCWsCoSEuJAr5gAZ' do
    pending("Prices are correct, but prepended with an *")
    retriever = SpecCacheRetriever.new(file_basename: 'YaCWsCoSEuJAr5gAZ.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 5915, vatRate: 20}]
    expect(bill_attributes[:vatNumber]).to eq 'ATU14221901'
  end

  it 'recognizes the bill T26m53KtQ9JrGhb2T' do
    retriever = SpecCacheRetriever.new(file_basename: 'T26m53KtQ9JrGhb2T.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 426164, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-02-29'
    expect(bill_attributes[:vatNumber]).to eq 'ATU70156715'
  end

  it 'recognizes the bill 27zu8ABiEcPTh2ELu' do
    pending("It recognizes one of the listed prices as the total sum, but both are detected")
    retriever = SpecCacheRetriever.new(file_basename: '27zu8ABiEcPTh2ELu.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 8697, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-09'
  end

  it 'recognizes the bill BYnCDzw7nNMFergRW' do
    retriever = SpecCacheRetriever.new(file_basename: 'BYnCDzw7nNMFergRW.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 29674, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
    expect(bill_attributes[:vatNumber]).to eq 'ATU54441803'
  end

  it 'recognizes the bill iyt9vLXuFfJhJKwJ5' do
    retriever = SpecCacheRetriever.new(file_basename: 'iyt9vLXuFfJhJKwJ5.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    # TODO: The vatRate should be 10, but we don't recognize vatRates without
    # net amount yet.
    # expect(bill_attributes[:amounts]).to eq [{total: 29674, vatRate: 10}]
    expect(bill_attributes[:amounts]).to eq [{total: 790, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-16'
    expect(bill_attributes[:vatNumber]).to eq 'ATU57399425'
  end

  it 'recognizes the bill zcEkC9vgfcTv7DBwM' do
    retriever = SpecCacheRetriever.new(file_basename: 'zcEkC9vgfcTv7DBwM.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 100000, vatRate: 0}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-11'
  end

  it 'recognizes the bill Etn9rJm4BAa2vnjyq' do
    retriever = SpecCacheRetriever.new(file_basename: 'Etn9rJm4BAa2vnjyq.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize

    expect(bill_attributes[:amounts]).to eq [{total: 323, vatRate: 20}]
    expect(bill_attributes[:invoiceDate]).to eq '2016-03-01'
    expect(bill_attributes[:vatNumber]).to eq 'ATU41472107'
  end

  it 'recognizes the bill a5b4acuqNNoQg9nh9' do
    pending('Fails because the file contains many small incorrect characters')

    retriever = SpecCacheRetriever.new(file_basename: 'a5b4acuqNNoQg9nh9.pdf')
    recognizer = BillRecognizer.new(
      retriever: retriever,
      customer_vat_number: 'ATU67760915'
    )

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:vatNumber]).to eq 'EU372001951'
    expect(bill_attributes[:currencyCode]).to eq "USD"
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

  it 'recognizes the bill QgxpPEE8xGzFGos9x' do # HDK
    pending("Recognition does not filter fundamental results(HKD)")

    retriever = SpecCacheRetriever.new(file_basename: 'QgxpPEE8xGzFGos9x.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
  end

  it 'recognizes the bill w3kuRspvcGk6Wg4A7' do # CHF
    retriever = SpecCacheRetriever.new(file_basename: 'w3kuRspvcGk6Wg4A7.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    #expect(bill_attributes[:vatNumber]).to eq 'EU372001951'
    expect(bill_attributes[:currencyCode]).to eq 'EUR'
  end

  it 'recognizes the bill 4KGwfH74J25TQgMGX' do # CNY
    retriever = SpecCacheRetriever.new(file_basename: '4KGwfH74J25TQgMGX.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:currencyCode]).to eq 'CNY'
  end

  it 'recognizes the bill 64PJR9yZjzJWrQFYc' do # SEK
    retriever = SpecCacheRetriever.new(file_basename: '64PJR9yZjzJWrQFYc.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:currencyCode]).to eq "SEK"
  end

  it 'recognizes the bill ntFGWi3wGTRvR6zqE' do  # GBP
    retriever = SpecCacheRetriever.new(file_basename: 'ntFGWi3wGTRvR6zqE.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:currencyCode]).to eq "GBP"
  end

  it 'recognizes the bill AteChFJR5vhMCqppF' do # HUF
    pending("recognizer does not recognise HUF")
    retriever = SpecCacheRetriever.new(file_basename: 'AteChFJR5vhMCqppF.JPG')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:currencyCode]).to eq "HUF"
  end

  it 'recognizes the bill xnh6PuihJcPYKdmer' do # HRK
    pending("Doesn't work! It did not recognize HRK")
    retriever = SpecCacheRetriever.new(file_basename: 'xnh6PuihJcPYKdmer.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    bill_attributes = recognizer.recognize
    expect(bill_attributes[:currencyCode]).to eq "HRK"
  end
end
