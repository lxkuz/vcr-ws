# VcrWs

This gem is designed for testing WebSocket (WS) clients. It is inspired by the VCR gem, which is widely used for REST API testing.

When you run the first RSpec test, the gem generates a YAML file containing all sent and received WebSocket data. On subsequent RSpec runs, it starts a mock WebSocket server that uses this YAML file and intercepts the WebSocket client's calls.

With this setup, you no longer need external WebSocket connections for unit testing.

**Warning**:

It works for `faye-websocket` WS client only.

## Installation

```bash
bundle add vcr_ws
```

## Usage

1. Configure your VCR WS:

```ruby
# spec_helper.rb

require "vcr_ws"

config = VcrWs::Config.instance
config.configure(
  # folder for VCR records
  file_base_path: "spec/fixtures",

  # VCR WS server host
  test_ws_address: "0.0.0.0",

  # VCR WS server port
  test_ws_port: 8080
)

RSpec.configure do |config|
  VcrWs::Rspec.configure(config)
end

```

2. Use it in your tests:

```ruby

# some_your_spec.rb

it 'your client should work', vcr_ws: 'test_sample' do
  # your client test code is here
  # first time it will call original WS server
  # after second call it uses `spec/fixtures/test_sample.yml` recorded data in test
end

```

Hint:

* Your websocket client should be an instance of `Faye::WebSocket::Client`
* That's a good approach to test your client in working in separate Thread and saving logs in array data. See example `spec/general_spec.rb`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/vcr_ws. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/vcr_ws/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the VcrWs project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/vcr_ws/blob/main/CODE_OF_CONDUCT.md).
