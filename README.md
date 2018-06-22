# Spaceborne

Welcome to spaceborne. Your new tool for testing of RESTful APIs. This builds on the great work of brooklyn/airborne, which I think is very useful, but has some major shortcomings. It also leverages curlyrest which allows easily adding a header parameter to an API request, and causes the request to be processed/exposed as a curl command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spaceborne'
```

And then execute:

```ruby
$ bundle
```

Or install it yourself as:

```ruby
$ gem install spaceborne
```

## Creating API tests

### Making a request

Spaceborne/airborne use curlyrest/rest-client to make the API requests. These are done in the manner that you actually think about the request, the http action verb, the url, headers, and body(optional depending on the verb). When creating a test, you can call any of the following methods: get, post, put, patch, delete, head, options.

#### Parts of a request

| part | description | restrictions |
|:--- |:----|:----|
|url|uri describing destination of the request|not including query/fragment|
|headers|hash of request headers|*optional request modifiers*|
|body|data being passed in the request|not on head/get requests|
|query|data passed on url after '?'|added as a 'params' hash in headers|

#### Optional request modifiers
These are passed as headers, but will be removed from the actual request, taking the desired effect.

| modifier | values | effect|
|:---|:---|:---|
|:use_curl| true, 'debug'|executes the command via curl, and if 'debug', output the command and response|
|:use_proxy| url of the proxy | sends the request to the proxy |
|:nonjson_data|true|forces content-type to application/x-www-form-urlencoded|

#### Request examples
passing request headers

```ruby
get 'http://example.com/api/v1/my_api', { 'x-auth-token' => 'my_token' }
```

passing a body (`post`, `put`, `patch`, `delete`) as a hash

```ruby
post 'http://example.com/api/v1/my_api', { :name => 'John Doe' }, { 'x-auth-token' => 'my_token' }
```

passing Query params via headers

```ruby
post 'http://example.com/api/v1/my_api', { }, { 'params' => {'param_key' => 'param_value' } }
```

make the request using curl and show me the entire request/response

```ruby
get 'http://example.com/api/v1/my_api', { 'x-auth-token' => 'my_token', use_curl: 'debug' }
```


### Validating a response

Most of the power of spaceborne comes from being able to write expectations in a compact form that has great power at being able to perform the actual validation you have in mind. This allows you to build up positive and negative test cases and choose what parts of the response are important, or ignored. Here's an example that we'll look at.

```ruby
require 'spaceborne'

describe 'simple get sample' do
  it 'should pass validation' do
    wrap_request do
      get 'http://example.com/api/v1/simple_get' #json api that returns { "name" : "John Doe" }
      expect_json_types(name: :string)
      expect_json(name: 'John Doe')
    end
  end
end
```
The parts of the example outside of the wrap_request block are typical rspec. The wrap_request is a spaceborne concept, saying that if anything fails inside of the block, to ouput to stdout information about the request, and response. This is to work around the issue of an expectation failing, and having good info about why, but having no idea what the request or response were that caused the failure. The actual request is done on the get line. Validation of the response is the following expect_ lines.

#### Parts of response to validate

* HTTP Status
	* `expect_status`(200) - expect to get a status of 200
* Headers
	* `expect_header`(validators)
	* `expect_header_types`(validators)
* JSON
	* `expect_json`(validators)
	* `expect_json`(path, validators)
	* `expect_json_types`(validators)
	* `expect_json_types`(path, validators)
	* `expect_json_keys`(validators)
	* `expect_json_keys`(path, validators)
	* `expect_json_sizes`(validators)
	* `expect_json_sizes`(path, validators)

##### Validators
The validators mimic the structure of the response you're validating. For example, if your API returns the following json on a get call with Alex specified in the URL:

```ruby
{
  "name": "Alex",
  "address": {
    "street": "Area 51",
    "city": "Roswell",
    "state": "NM",
    "coordinates": {
      "latitude": 33.3872,
      "longitude": 104.5281 } },
  "phones": [
    { "type": "cell",
      "number": "123-456-7890"},
    { "type": "home",
      "number": "987-654-3210"} ]
}
```

some possible validations are:

```ruby
expect_json(name: 'Alex') # exact match because you asked for Alex
expect_json_types(name: :string, address: {street: :string, city: :string, state: :string,
  coordinates: {latitude: :float, longitude: :float}},
  phones: :array_of_objects) # all the types and structure (cannot go into arrays this way)
expect_json('address', state: /^[A-Z]{2}$/) # ensures address/state has 2 capital letters
expect_json_types('phones.*', type: :string, number: :string) # looks at all elements in array
expect_json_types('phones.1', type: :string, number: :string) # looks at second element in array
expect_json_keys('address', [:street, :city, :state, :coordinates]) # ensure specified keys present
expect_json_sizes(phones: 2) # expect the phones array size to be 2
```

When calling `expect_json` or `expect_json_types`, you can optionally provide a block and run your own `rspec` expectations:

```ruby
describe 'sample spec' do
  it 'should validate types' do
    get 'http://example.com/api/v1/simple_get' #json api that returns { "name" : "John Doe" }
    expect_json(name: -> (name){ expect(name.length).to eq(8) })
  end
end
```

When calling `expect_*_types`, these are the valid types that can be tested against:

* `:int` or `:integer`
* `:float`
* `:bool` or `:boolean`
* `:string`
* `:date`
* `:object`
* `:null`
* `:array`
* `:array_of_integers` or `:array_of_ints`
* `:array_of_floats`
* `:array_of_strings`
* `:array_of_booleans` or `:array_of_bools`
* `:array_of_objects`
* `:array_of_arrays`

If the properties are optional and may not appear in the response, you can append `_or_null` to the types above.


	
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
