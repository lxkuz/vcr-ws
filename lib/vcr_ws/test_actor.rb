# frozen_string_literal: true

require "vcr_ws"

def test
  config = VcrWs::Config.instance
  config.configure(
    test_ws_port: 8082,
    test_ws_address: "0.0.0.0"
  )
  file_path = "spec/fixtures/sample.yml"
  @actor_ws = VcrWs::ActorWS.new(file_path)
  @actor_ws.start!
end

test
