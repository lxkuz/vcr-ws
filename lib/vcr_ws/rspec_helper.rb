# RSpec Integration
module VcrWs
  module RspecHelper
    def start_ws_vcr_server!(file_path)
      @actor_ws = VcrWs::ActorWS.new(file_path)
      @actor_ws.start!
      VcrWs::ClientActorMiddleware.enable_actor!
      VcrWs::Config.instance.vcr_enabled = true
    end

    def stop_ws_vcr_server!
      @actor_ws.stop! if @actor_ws
      VcrWs::Config.instance.vcr_enabled = false
    end

    def enable_ws_recording!(recorder_file)
      VcrWs::ClientRecorderMiddleware.enable_recorder!(recorder_file)
    end
  end
end


