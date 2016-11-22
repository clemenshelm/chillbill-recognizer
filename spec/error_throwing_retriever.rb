# frozen_string_literal: true
require_relative './spec_cache'
require_relative '../lib/bill_image_retriever'

class ErrorThrowingRetriever
  include SpecCache

  def initialize(file_basename:)
    @file_basename = file_basename
  end

  def save
    file_extension = File.extname @file_basename.downcase
    raise UnprocessableFileError.new(
      'Unprocessable file type: ', file_extension
    )
  end
end
