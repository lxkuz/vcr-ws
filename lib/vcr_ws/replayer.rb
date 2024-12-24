# frozen_string_literal: true
require 'yaml'

module VcrWs
  class Replayer
    def initialize(file_path)
      @file_path = file_path
      @replay_data = nil
      @start_time = nil
    end

    def load
      if File.exist?(@file_path)
        @replay_data = YAML.load_file(@file_path)
      end
    end

    def next_event
      load if @replay_data.nil?
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
