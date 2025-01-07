

module VcrWs
  class ClientActorMiddleware
    def self.enable_actor!
      Faye::WebSocket::Client.prepend(
        Module.new do
          def initialize(url, protocols = nil, options = {})
            if VcrWs::Config.instance.vcr_enabled
              puts 'actor middleware initialize'
              actor_url = "wss://#{VcrWs::Config.instance.test_ws_address}:#{VcrWs::Config.instance.test_ws_port}"
              puts 'new url: ' + actor_url
              super(actor_url, protocols, options)
            else
              super
            end
          end
        end
      )
    end
  end
end
