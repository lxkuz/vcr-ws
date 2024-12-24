# frozen_string_literal: true

require "vcr_ws"

config = VcrWs::Config.instance
config.configure({})

RSpec.configure do |config|
  VcrWs::Rspec.configure(config)
end
