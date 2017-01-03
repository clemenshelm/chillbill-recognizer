# frozen_string_literal: true
require_relative './error_throwing_retriever.rb'
require_relative '../lib/bill_recognizer.rb'

describe 'BillRecognizer' do
  it 'rejects bill with unknown file formats' do
    retriever = ErrorThrowingRetriever.new(
      file_basename: 'xcaEpkmTauDsZz9fk.p7s'
    )
    recognizer = BillRecognizer.new(retriever: retriever)

    version_data = YAML.load_file './lib/version.yml'
    version = version_data['Version']

    expect(recognizer.recognize[:error]).to eq 'Unprocessable file type: .p7s'
    expect(recognizer.recognize[:recognizerVersion]).to eq version
  end

  it 'reports when a bill cannot be read' do
    # This spec will fail once Ghostscript supports this crappy PDF. Awesome!
    retriever = SpecCacheRetriever.new(file_basename: '5CCkGCCprokPBy2o6.pdf')
    recognizer = BillRecognizer.new(retriever: retriever)

    expect(recognizer.recognize[:error]).to start_with 'Cannot read image.'
  end
end
