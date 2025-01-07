require 'rspec'
require 'faye/websocket'
require 'eventmachine'

RSpec.describe 'Echo WebSocket Server' do
  let(:host) do
    '0.0.0.0'
  end

  let(:echo_port) do
    8080
  end

  let(:vcr_port) do
    8089
  end

  let(:logger) do
    TestLogger.new
  end

  before(:each) do
    @thread = start_echo_server(host, echo_port)
  end

  after(:each) do
    Thread.kill(@thread) if @thread.alive?
  end

  let(:expected_logs) do
    [
      [:info, 'connection opened'],
      [:info, 'message: hello'],
      [:info, 'message: test'],
      [:info, 'message: test 2'],
      [:info, 'connection closed']
    ]
  end

  it 'sends "hello" on connection' do
    Thread.new do
      EM.run do
        client = Faye::WebSocket::Client.new("ws://#{host}:#{echo_port}")

        client.on :open do
          logger.info('connection opened')
          client.send('test')
        end

        client.on :message do |event|
          logger.info("message: #{event.data}")
        end

        client.on :close do
          logger.info("connection closed")
          EM.stop
        end

        sleep 3
        client.send('stop')
      end
    end.run
    sleep 6
    expect(logger.logs).to eql(expected_logs)
  end
end
