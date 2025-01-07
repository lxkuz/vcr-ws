

require 'faye/websocket'
require 'eventmachine'
require 'em-websocket'
require 'yaml'
require 'rspec'

require_relative "vcr_ws/version"
require_relative "vcr_ws/config"
require_relative "vcr_ws/recorder"
require_relative "vcr_ws/actor_ws"
require_relative "vcr_ws/rspec_helper"
require_relative "vcr_ws/client_recorder_middleware"
require_relative "vcr_ws/client_actor_middleware"
require_relative "vcr_ws/rspec"

module VcrWs
  class Error < StandardError; end
  # Your code goes here...
end
