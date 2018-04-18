# Spaceborne

Welcome to spaceborne. Your new tool for testing of RESTful APIs. This builds on the great work of brooklyn/airborne, which I think is very useful, but has some major shortcomings. It also leverages curlyrest which allows easily adding a header parameter to an API request, and causes the request to be processed/exposed as a curl command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spaceborne'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spaceborne

## Creating API tests

```ruby
require 'spaceborne'

describe 'sample spec' do
  it 'should validate types' do
    wrap_request do
      get 'http://example.com/api/v1/simple_get' #json api that returns { "name" : "John Doe" }
      expect_json_types(name: :string)
    end
  end

  it 'should validate values' do
    wrap_request do
      get 'http://example.com/api/v1/simple_get' #json api that returns { "name" : "John Doe" }
      expect_json(name: 'John Doe')
    end
  end
end
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Extensions to Airborne

1. Uses curlyrest to allow extension of rest-client with curl requests
2. Bundles groups of expectations so that if any fail, you will actually see the request and response printed out, rather than just seeing the expectation that failed
3. json_body is only calculated once after request rather than on each call
4. Expectations for headers use the same form as the expectations for json bodies
  * `expect_header same arguments/handling as expect_json`
  * `expect_header_types same arguments/handling as expect_json_types`
5. Expectations returning a hash with keys that are unknown, but that have a defined structure are supported
6. It is possible to use non-json data in a request

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/keithrw54/spaceborne.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
