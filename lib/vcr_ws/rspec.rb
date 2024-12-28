require 'rspec'
require 'vcr_ws/config'
require 'vcr_ws/rspec_helper'
require 'pry'

module VcrWs
  class Rspec
    def self.configure(rspec_config)
      rspec_config.include VcrWs::RspecHelper

      rspec_config.before(:each, vcr_ws: true) do |example|
        file_path = example.metadata[:vcr_ws]
        raise 'vcr_ws file path is required!' unless file_path

        full_path = File.join(VcrWs::Config.instance.file_base_path, file_path)
        full_path = full_path + '.yml' unless File.extname(full_path) == '.yml'
        if File.exist?(full_path)
          start_ws_vcr_server!(full_path)
        else
          enable_ws_recording!(full_path)
        end
      end

      rspec_config.after(:each, vcr_ws: true) do |_example|
        stop_ws_vcr_server!
      end
    end
  end
end

