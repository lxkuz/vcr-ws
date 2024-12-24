module VcrWs
  class Middleware
    def initialize(client, recorder)
      @client = client
      @recorder = recorder
    end

    def on(event, &block)
      @client.on(event) do |data|
        @recorder.record(event, format_data(event, data))
        block.call(data) if block
      end
    end

    def send(data)
      @client.send(data)
    end

    def close(code = nil, reason = nil)
      @client.close(code, reason)
    end

    private

    def format_data(event, data)
      case event
      when :message then data.data
      when :close then { code: data.code, reason: data.reason }
      else nil
      end
    end
  end

  def self.enable_recorder!(recorder_file)
    Faye::WebSocket::Client.prepend(Module.new do
      def initialize(url, protocols = nil, options = {})
        @recorder = WebSocketVCR::Recorder.new(recorder_file)
        super
        @middleware = WebSocketVCR::Middleware::RecorderMiddleware.new(self, @recorder)
      end

      def on(event, &block)
        @middleware.on(event, &block)
      end
    end)
  end
end
end
