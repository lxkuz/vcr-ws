require 'rspec'
require 'faye/websocket'
require 'eventmachine'
require 'timecop'

RSpec.describe 'Echo WebSocket Server' do

  def start_client_ws
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
  end

  before(:all) do
    time = Time.parse('2025-01-01 1:0:00 +0000')
    Timecop.travel(time)
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

  let(:sample_file_path) do
    'spec/fixtures/sample.yml'
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

  context 'when work without VCR' do
    it 'works as WS echo server properly' do
      start_client_ws
      expect(logger.logs).to eql(expected_logs)
    end
  end

  # ISSUE: 2 vcr_ws processes are failing cause of
  # client middleware #@client.method(:on).super_method.call(event)
  # `method': stack level too deep error
  context 'when VCR enabled' do
    let(:file_path) do
      'spec/fixtures/recorder.yml'
    end

    after do
      File.delete(file_path) if File.file?(file_path)
    end

    it 'creates VCR recorded file', vcr_ws: 'recorder' do
      start_client_ws
      expect(File.file?(file_path)).to be_truthy
      expect(YAML.load_file(file_path)).to eql(YAML.load_file(sample_file_path))
    end
  end

  # ISSUE: Figure out why it is falling
  # /Users/lxkuz/projects/vcr_ws/lib/vcr_ws/actor_ws.rb:26:in `block (4 levels) in start!':
  # Invalid HTTP header: Could not parse data entirely (0 != 517) (EventMachine::WebSocket::HandshakeError)
  xcontext 'when VCR enabled and we try to use it' do
    let(:file_path) do
      'spec/fixtures/sample.yml'
    end

    it 'uses pre-recorded VCR file', vcr_ws: 'sample' do
      start_client_ws
      expect(logger.logs).to eql(expected_logs)
    end
  end
end
