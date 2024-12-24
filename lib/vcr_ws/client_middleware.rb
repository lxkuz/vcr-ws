module VcrWs
  class ClientMiddleware
    def self.enable_recorder!(recorder_file)
      VcrWs::Config.instance.current_file_path = recorder_file

      Faye::WebSocket::Client.prepend(
        Module.new do
          def initialize(url, protocols = nil, options = {})
            @recorder = VcrWs::Recorder.new(VcrWs::Config.instance.current_file_path)
            super
            @middleware = VcrWs::ClientMiddleware.new(self, @recorder)
          end

          def on(event, &block)
            # Call the original method using `super` and pass through the middleware
            @middleware.on(event, block)
          end

          def send(message)
            # Call the original method using `super` and pass through the middleware
            @middleware.send_message(message)
          end
        end
      )
    end

    def initialize(client, recorder)
      @client = client
      @recorder = recorder
    end

    def on(event, block)
      @client.method(:on).super_method.call(event) do |data|
        value = nil
        if data.respond_to?(:data)
          value = data.data
        end
        @recorder.record(event, value)
        block.call(data) if block
      end
    end

    def send_message(message)
      @recorder.record('send', message)
      @client.method(:send).super_method.call(message)
    end

    private

    # def format_data(event, data)
    #   case event
    #   when :open then dat``
    #   when :message then dat``
    #   when :close then { code: data.code, reason: data.reason }
    #   else raise("Undefined format for event: #{event}")
    #   end
    # end
  end
end
