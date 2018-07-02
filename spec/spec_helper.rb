require 'simplecov'
SimpleCov.start

require 'airborne'
require 'spaceborne'
require 'curlyrest'
require 'stub_helper'

Airborne.configure do |config|
  config.base_url = 'http://www.example.com'
  config.include StubHelper
end

ExpectationNotMetError = RSpec::Expectations::ExpectationNotMetError
ExpectationError       = Airborne::ExpectationError
InvalidJsonError       = Airborne::InvalidJsonError
PathError              = Airborne::PathError
