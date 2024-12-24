# frozen_string_literal: true

module VcrWs
  class Config
    cattr_accessor :file_base_path

    def self.configure(options)
      file_base_path = options[:base_path] || "./spec/fixtures/vcr_ws"
    end
  end
end
