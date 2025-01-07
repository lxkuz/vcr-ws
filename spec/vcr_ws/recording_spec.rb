require 'rspec'
require 'faye/websocket'
require 'eventmachine'
require 'timecop'

RSpec.describe 'Echo WebSocket Server' do

  before(:all) do
    new_time = Time.local(2025, 1, 1, 1, 0, 0)
    Timecop.freeze(new_time)
  end

  after(:all) do
    Timecop.return
  end

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
    VcrWs::Config.instance.test_ws_port = vcr_port
    # File.remove()
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

  before do

  end

  context 'when work without VCR' do
  it 'works as WS echo server properly' do
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

context 'when VCR enabled' do
  let(:file_path) do
    'spec/fixtures/recorder.yml'
  end

  after do
    File.delete(file_path) if File.file?(file_path)
  end
  it 'creates VCR recorded file', vcr_ws: 'recorder' do
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
    expect(File.file?(file_path)).to be_truthy
    expect(YAML.load_file(file_path)).to eql(
      [
        {:event => :open, :timestamp => 1735675200.0},
        {:data => "test", :event => "send", :timestamp => 1735675200.0},
        {:data => "hello", :event => :message, :timestamp => 1735675200.0},
        {:data => "test", :event => :message, :timestamp => 1735675200.0},
        {:data => "test 2", :event => :message, :timestamp => 1735675200.0},
        {:data => "stop", :event => "send", :timestamp => 1735675200.0},
        {:event => :close, :timestamp => 1735675200.0}
      ]
    )
  end
end
end
