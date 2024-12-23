# frozen_string_literal: true

module VcrWs
  class Recorder
    def initialize
      @recording = []
    end

    def record(event, data)
      @recording << { timestamp: Time.now.to_f, event: event, data: data }
    end

    def save
      File.open(RECORD_FILE, 'w') { |f| f.write(YAML.dump(@recording)) }
    end
  end

  class Replayer
    def initialize(file_path)
      @replay_data = YAML.load_file(file_path)
      @start_time = nil
    end

    def next_event
      return nil if @replay_data.empty?

      event = @replay_data.first
      delay = @start_time.nil? ? 0 : event[:timestamp] - @start_time
      @start_time = event[:timestamp] if @start_time.nil?

      { delay: delay, event: event[:event], data: event[:data] }
    ensure
      @replay_data.shift
    end
  end
end
