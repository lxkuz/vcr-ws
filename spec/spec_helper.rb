require "vcr_ws"
require 'eventmachine'
require 'em-websocket'

config = VcrWs::Config.instance
config.configure(
  file_base_path: 'spec/fixtures',
  test_ws_address: '0.0.0.0'
)

RSpec.configure do |config|
  VcrWs::Rspec.configure(config)
end

class TestLogger
  attr_reader :logs

  def initialize
    @logs = []
  end

  def info(msg)
    @logs.push([:info, msg])
  end

  def error(msg)
    @logs.push([:error, msg])
  end
end

def start_echo_server(host, port)
  thread = Thread.new(host, port) do |host, port|
    EM.run do
      puts "Starting WebSocket server on ws://#{host}:#{port}"

      EM::WebSocket.start(host: host, port: port) do |ws|
        ws.onopen do
          puts "Client connected"
          ws.send("hello")
        end

        ws.onmessage do |message|
          puts "Received message: #{message}"

          if message == 'stop'
            puts 'STOPING'
            ws.close
            EM.stop
          else
            ws.send(message)

            EM.add_timer(1) do
              ws.send("#{message} 2")
            end
          end
        end

        ws.onclose do
          puts "Client disconnected"
        end

        ws.onerror do |error|
          puts "Error: #{error.message}"
          puts error.backtrace
        end
      end
    end
  end.run
  thread
end
