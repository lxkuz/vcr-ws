require 'singleton'

module VcrWs
  class Config
    include Singleton

    def initialize
      @settings = {
        file_base_path: "./spec/fixtures/vcr_ws",
        current_file_path: nil,
        test_ws_port: 8080,
        test_ws_address: '0.0.0.0'
      }
    end

    class << self
      # Define dynamic getters and setters for all keys in a loop
      def define_config_keys(*keys)
        keys.each do |key|
          define_method(key) do
            @settings[key]
          end

          define_method("#{key}=") do |value|
            @settings[key] = value
          end
        end
      end
    end

    # Reset all settings to defaults
    def reset!
      @settings = {
        file_base_path: "./spec/fixtures/vcr_ws",
        current_file_path: nil,
        test_ws_port: 8080,
        test_ws_address: '0.0.0.0'
      }
    end

    # Configure multiple settings at once
    def configure(options = {})
      options.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end

  # Define all configuration keys at once
  Config.define_config_keys(
    :file_base_path,
    :current_file_path,
    :test_ws_port,
    :test_ws_address
  )
end