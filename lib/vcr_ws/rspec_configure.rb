require 'rspec'
require 'vcr_ws/config'

RSpec.configure do |config|
  config.include WebSocketVCRRSpec

  config.before(:all, vcr_ws: true) do |example|
    file_path = example.metadata[:vcr_ws]
    raise 'vcr_ws file path is required!' unless file_path

    start_ws_vcr_server!(File.join(Config.file_base_path, file_path))
  end

  config.after(:all, vcr_ws: true) do |_example|
    stop_ws_vcr_server!
  end
end
