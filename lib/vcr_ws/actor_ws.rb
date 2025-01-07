module VcrWs
  class ActorWS
    def initialize(file_path)
      @events = load_events(file_path)
      @event_index = 0
    end

    def start!
      cnf = VcrWs::Config.instance
      @thread = Thread.new(cnf.test_ws_address, cnf.test_ws_port) do |host, port|
        Thread.handle_interrupt(RuntimeError => :never) do
          # You can write resource allocation code safely.
          Thread.handle_interrupt(RuntimeError => :immediate) do
            EM.run do
              puts "Starting VCR WebSocket server on ws://#{host}:#{port}"
              EM::WebSocket.start(host:, port:) do |ws|
                ws.onopen do
                  handle_open(ws)
                end

                ws.onmessage do |message|
                  receive_message(ws, message)
                end

                ws.onclose do
                  handle_close(ws)
                end

                ws.onerror do |error|
                  puts "VCR::Error: #{error.message}"
                  puts error.backtrace
                end
              end
            end
          end
        ensure
          EM.stop if EM.reactor_running?
        end
      end.run
      sleep 3
    end

    def stop!
      EM.stop if EM.reactor_running?
    end

    private

    def load_events(file_path)
      YAML.load_file(file_path, symbolize_names: true)
    end

    def handle_open(ws)
      @event_index = 0
      process_next_event(ws)
    end

    def handle_close(ws)
      process_next_event(ws)
    end

    def receive_message(ws, message)
      current_event = @events[@event_index]
      if current_event[:event].to_sym == :client_send
        unless message == current_event[:data]
          raise VcrWs::Error, "Mismatch error: Expected #{current_event[:data]}, got #{message}"
        end

        @event_index += 1
        process_next_event(ws)
      else
        raise VcrWs::Error, "Unexpected message received: #{message}"
      end
    end

    def process_next_event(ws = 0)
      next_event = @events[@event_index]

      return unless next_event

      delay = calculate_delay(next_event[:timestamp])

      EM.add_timer(delay) do
        case next_event[:event].to_sym
        when :open
          ws.send(next_event[:data]) if next_event[:data]
          @event_index += 1
        when :message
          ws.send(next_event[:data]) if next_event[:data]
          @event_index += 1
          process_next_event(ws)
        when :close
          ws.send(next_event[:data]) if next_event[:data]
          ws.close
        when :client_send
          # puts "Waiting for client to send: #{next_event[:data]}"
        else
          raise VcrWs::Error, "Unhandled event: #{next_event[:event]}"
          process_next_event(ws)
        end
      end
    end

    def calculate_delay(timestamp)
      return 0 if @event_index.zero?

      previous_timestamp = @events[@event_index - 1][:timestamp]
      [timestamp - previous_timestamp, 0].max
    end
  end
end
