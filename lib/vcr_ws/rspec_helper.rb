# frozen_string_literal: true

# RSpec Integration
module VcrWs
  module RspecHelper
    def start_ws_vcr_server!(file_path)
      @actor_ws = VcrWs::ActorWS.new(file_path)
      @actor_thread = @actor_ws.start!
      VcrWs::Config.instance.vcr_enabled = true
      VcrWs::ClientActorMiddleware.enable_actor!
    end

    def stop_ws_vcr_server!
      @actor_ws&.stop!
      VcrWs::Config.instance.vcr_enabled = false
    end

    def enable_ws_recording!(recorder_file)
      VcrWs::ClientRecorderMiddleware.enable_recorder!(recorder_file)
    end
  end
end
