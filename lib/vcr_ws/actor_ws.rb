# frozen_string_literal: true
require 'eventmachine'

require 'vcr_ws/replayer'

module VcrWs
  class ActorWS
    def initialize(file_path)
      @replayer = VcrWs::Replayer.new(file_path)
      @connections = []
    end

    def start!
      Thread.new do
        EM.run do
          EM.start_server('0.0.0.0', 8080, ConnectionHandler, @replayer, @connections)
        end
      end
    end

    def stop!
      EM.stop if EM.reactor_running?
    end

    class ConnectionHandler < EM::Connection
      def initialize(replayer, connections)
        @replayer = replayer
        @connections = connections
        @ws = Faye::WebSocket::Adapter.new(self)
      end

      def post_init
        @connections << self
      end

      def receive_data(data)
        @ws.receive(data)
      end

      def unbind
        @connections.delete(self)
      end

      def ws_open
        EM.add_periodic_timer(0.1) do
          next_event = @replayer.next_event
          if next_event
            EM.add_timer(next_event[:delay]) do
              send_data(next_event[:data]) if next_event[:event] == 'message'
            end
          end
        end
      end

      def ws_close
        close_connection_after_writing
      end

      def ws_message(data)
        # Handle incoming messages if necessary
      end
    end
  end
end