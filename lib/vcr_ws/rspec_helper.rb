# RSpec Integration
module VcrWs
  module SpecHelper
    def start_ws_vcr_server!(file_path)
      @actor_ws = VcrWs::ActorWS.new(file_path)
      @actor_ws.start!
    end

    def stop_ws_vcr_server!
      @actor_ws.stop! if @actor_ws
    end

    def enable_ws_recording!(recorder_file)
      VcrWs::ClientMiddleware.enable_recorder!(recorder_file)
    end
  end
end