# frozen_string_literal: true

require "rspec"
require "faye/websocket"
require "eventmachine"
require "timecop"

RSpec.describe "General VCR test" do
  def start_client_ws
    @client_thread = Thread.new do
      EM.run do
        connect_line = "ws://#{host}:#{echo_port}"
        client = Faye::WebSocket::Client.new(connect_line)

        client.on :open do
          logger.info("connection opened")
          client.send("test")
        end

        client.on :message do |event|
          logger.info("message: #{event.data}")
        end

        client.on :close do
          logger.info("connection closed")
          EM.stop
        end

        sleep 3
        client.send("stop")
      end
    end.run
    sleep 6
  end

  def stop_client_ws
    EM.stop if EM.reactor_running?
    Thread.kill(@client_thread) if @client_thread.alive?
  end

  after(:all) do
    Timecop.return
  end

  let(:host) do
    "0.0.0.0"
  end

  let(:echo_port) do
    8080
  end

  let(:logger) do
    TestLogger.new
  end

  let(:sample_file_path) do
    "spec/fixtures/sample.yml"
  end

  let(:expected_logs) do
    [
      [:info, "connection opened"],
      [:info, "message: hello"],
      [:info, "message: test"],
      [:info, "message: test 2"],
      [:info, "connection closed"]
    ]
  end

  before(:all) do
    vcr_port = 8089
    VcrWs::Config.instance.test_ws_port = vcr_port
  end

  after do
    stop_client_ws
  end

  before do
    time = Time.parse("2025-01-01 1:0:00 +0000")
    Timecop.travel(time)
  end

  context "when LIVE WS server is ON" do
    before(:each) do
      @thread = start_echo_server(host, echo_port)
    end

    after(:each) do
      Thread.kill(@thread) if @thread.alive?
    end

    context "when work without VCR" do
      it "works as WS echo server properly" do
        start_client_ws
        expect(logger.logs).to eql(expected_logs)
      end
    end

    context "when VCR enabled" do
      let(:file_path) do
        "spec/fixtures/recorder.yml"
      end

      after do
        File.delete(file_path) if File.file?(file_path)
      end

      it "creates VCR recorded file", vcr_ws: "recorder" do
        start_client_ws
        expect(File.file?(file_path)).to be_truthy
        expect(YAML.load_file(file_path)).to eql(YAML.load_file(sample_file_path))
      end
    end
  end

  context "when VCR enabled and we try to use it" do
    before do
      # It takes 1 sec so I do it just to keep this timestamps equal
      sleep 1
    end

    let(:file_path) do
      "spec/fixtures/sample.yml"
    end

    it "uses pre-recorded VCR file", vcr_ws: "sample" do
      start_client_ws
      expect(logger.logs).to eql(expected_logs)
    end
  end
end
