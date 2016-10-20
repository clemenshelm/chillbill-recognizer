# frozen_string_literal: true
require 'null_logger'

module Logging
  class << self
    def logger
      @logger ||= NullLogger.new
    end

    attr_writer :logger
  end

  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    Logging.logger
  end
end
