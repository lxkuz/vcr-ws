module VcrWs
  class ActorWS
    def initialize(file_path)
      @events = load_events(file_path)
      @event_index = 0
    end

    def start!
      @thread = Thread.new do
        EM.run do
          cnf = VcrWs::Config.instance
          EM::WebSocket.start(host: cnf.test_ws_address, port: cnf.test_ws_port, debug: true) do |ws|
            ws.onopen do
              handle_open(ws)
            end

            ws.onmessage do |message, _type|
              handle_message(ws, message)
            end

            ws.onclose do
              handle_close(ws)
            end

            ws.onerror do |error|
              raise error
              puts "Error: #{error}"
            end
          end

          puts "WebSocket server started ws://#{cnf.test_ws_address}:#{cnf.test_ws_port}"
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
      puts "Client connected"
      process_next_event(ws)
    end

    def handle_message(ws, message)
      current_event = @events[@event_index]

      if current_event[:event] == :send
        unless message == current_event[:data]
          raise VcrWs::Error, "Mismatch error: Expected #{current_event[:data]}, got #{message}"
        end

        puts "Message matches expected data."
        @event_index += 1
        process_next_event(ws)

      else
        puts "Unexpected message received: #{message}"
      end
    end

    def handle_close(_ws)
      puts "Client disconnected"
    end

    def process_next_event(ws = 0)
      return if @event_index >= @events.size

      current_event = @events[@event_index]
      puts @events.inspect
      puts "current_event"
      puts current_event.inspect

      delay = calculate_delay(current_event[:timestamp])

      EM.add_timer(delay) do
        case current_event[:event]
        when :message
          ws.send(current_event[:data])
          puts "Sent message: #{current_event[:data]}"
          @event_index += 1
          process_next_event(ws)
        when :close
          puts "Closing connection"
          ws.close
        when :send
          puts "Waiting for client to send: #{current_event[:data]}"
        else
          puts "Unhandled event: #{current_event[:event]}"
          @event_index += 1
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
