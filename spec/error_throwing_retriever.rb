# frozen_string_literal: true
require_relative './spec_cache'
require_relative '../lib/bill_image_retriever'

class ErrorThrowingRetriever
  include SpecCache

  def initialize(file_basename:, recognizer_version:)
    @file_basename = file_basename
    @recognizer_version = recognizer_version
  end

  def save
    file_extension = File.extname @file_basename.downcase
    version = @recognizer_version
    failing_file = {
      extension: file_extension,
      version: version
    }
    raise UnprocessableFileError, failing_file
  end
end
