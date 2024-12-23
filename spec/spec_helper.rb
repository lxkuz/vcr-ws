# frozen_string_literal: true

require "vcr_ws"

RSpec.configure do |config|
  config.include WebSocketVCRRSpec

  config.before(:all, vcr_ws: true) do |example|
    file_path = example.metadata[:vcr_ws]
    raise 'vcr_ws file path is required!' unless file_path

    unless File.exist?(file_path)
      enable_ws_recording!(file_path)
    end

    start_ws_vcr_server!(file_path)
  end

  config.after(:all, vcr_ws: true) do |_example|
    stop_ws_vcr_server!
  end
end
