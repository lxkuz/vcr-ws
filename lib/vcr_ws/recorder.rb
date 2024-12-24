# frozen_string_literal: true

module VcrWs
  class Recorder
    def initialize(recorder_file)
      @recorder_file = recorder_file
      @recording = []
    end

    def record(event, data)
      @recording << { timestamp: Time.now.to_f, event: event, data: data }
    end

    def save
      File.open(@recorder_file, 'w') { |f| f.write(YAML.dump(@recording)) }
    end
  end
end
