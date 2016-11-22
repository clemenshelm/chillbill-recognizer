# frozen_string_literal: true
require_relative './error_throwing_retriever.rb'
require_relative '../lib/bill_recognizer.rb'

describe 'BillRecognizer' do
  it 'rejects bill with unknown file formats' do
    retriever = ErrorThrowingRetriever.new(
      file_basename: 'xcaEpkmTauDsZz9fk.p7s'
    )
    recognizer = BillRecognizer.new(retriever: retriever)

    expect(recognizer.recognize[:error]).to eq 'Unprocessable file type: .p7s'
  end
end
