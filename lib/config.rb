# frozen_string_literal: true
require 'yaml'

class Config
  @config_hash =
    begin
      environment = ENV['RECOGNIZER_ENV'] || 'development'
      config_yaml = ERB.new(IO.read('config.yml')).result
      YAML.load(config_yaml)[environment].freeze
    end

  def self.[](key)
    @config_hash[key.to_s]
  end
end
