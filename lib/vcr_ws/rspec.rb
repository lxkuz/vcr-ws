require 'rspec'
require 'vcr_ws/config'
require 'vcr_ws/spec_helper'

module VcrWs
  class Rspec
    def self.configure(rspec_config)
      rspec_config.include VcrWs::SpecHelper

      rspec_config.before(:all, vcr_ws: true) do |example|
      file_path = example.metadata[:vcr_ws]
      raise 'vcr_ws file path is required!' unless file_path

      start_ws_vcr_server!(File.join(VcrWs::Config.file_base_path, file_path))
    end

    rspec_config.after(:all, vcr_ws: true) do |_example|
      stop_ws_vcr_server!
    end
  end
end
