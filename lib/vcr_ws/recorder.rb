# frozen_string_literal: true

require 'fileutils'

module VcrWs
  class Recorder
    def initialize(recorder_file)
      dir = File.dirname(recorder_file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      @recorder_file = recorder_file
    end

    def record(event, data)
      line = { timestamp: Time.now.to_f, event: event }
      line[:data] = data if data
      full_data = if File.exists?(@recorder_file)
        YAML.load_file(@recorder_file, symbolize_names: true)
      else
        []
      end
      full_data.push(line)
      File.open(@recorder_file, 'w') { |f| f.write(YAML.dump(full_data)) }
    end
  end
end
