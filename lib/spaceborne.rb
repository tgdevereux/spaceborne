require 'airborne'
require "spaceborne/version"
require 'rest-client'
require 'byebug'
require 'json'

module Spaceborne
  def is_json?(headers)
    headers.has_key?(:content_type) && headers[:content_type].include?('application/json')
  end
  def wrap_request(&block)
    block.call
  rescue Exception => e
    puts "REQUEST: #{response.request.method.upcase} #{response.request.url}"
    puts "  HEADERS:\n#{JSON::pretty_generate(response.request.headers)}" 
    puts "  PAYLOAD:\n#{@request_body}" if @request_body
    puts "RESPONSE: #{response.code}"
    puts "  HEADERS:\n#{JSON::pretty_generate(response.headers)}"
    if is_json?(response.headers)
      puts "  JSON_BODY\n#{JSON::pretty_generate(json_body)}" 
    else
      puts "  BODY\n#{response.body}"
    end
    raise e
  end
end

module Airborne
  def json_body
    @json_body ||= JSON.parse(response.body, symbolize_names: true)
  rescue 
    fail InvalidJsonError, 'Api request returned invalid json'
  end
  module RestClientRequester
    def make_request(method, url, options = {})
      @json_body = nil
      @requet_body = nil
      headers = base_headers.merge(options[:headers] || {})
      res = if method == :post || method == :patch || method == :put
        begin
          @request_body = options[:body].nil? ? '' : options[:body]
          if options[:body].is_a?(Hash)
            if headers.delete(:nonjson_data)
              headers.delete('Content-Type')
            else
              headers.merge!(no_restclient_headers: true)
              @request_body = @request_body.to_json
            end
          end
          RestClient.send(method, get_url(url), @request_body, headers)
        rescue RestClient::Exception => e
          e.response
        end
      else
        begin
          RestClient.send(method, get_url(url), headers)
        rescue RestClient::Exception => e
          e.response
        end
      end
      res
    end

    private
    def base_headers
      { "Content-Type" => 'application/json' }.merge(Airborne.configuration.headers || {})
    end
  end

  module RequestExpectations
    def call_with_relative_path(data, args)
      if args.length == 2
        get_by_path(args[0], data) do |json_chunk|
          yield(args[1], json_chunk)
        end
      else
        yield(args[0], data)
      end
    end

    def expect_json_types(*args)
      call_with_relative_path(json_body, args) do |param, body|
        expect_json_types_impl(param, body)
      end
    end

    def expect_json(*args)
      call_with_relative_path(json_body, args) do |param, body|
        expect_json_impl(param, body)
      end
    end

    def expect_header_types(*args)
      call_with_relative_path(response.headers, args) do |param, body|
        expect_json_types_impl(param, body)
      end
    end

    def expect_header(*args)
      call_with_relative_path(response.headers, args) do |param, body|
        expect_json_impl(param, body)
      end
    end
  end

  module PathMatcher
    def get_by_path(path, json, &block)
      fail PathError, "Invalid Path, contains '..'" if /\.\./ =~ path
      type = false
      parts = path.split('.')
      parts.each_with_index do |part, index|
        if part == '*' || part == '?'
          ensure_array_or_hash(path, json)
          type = part
          if index < parts.length.pred
            walk_with_path(type, index, path, parts, json, &block) && return
          end
          next
        end
        begin
          json = process_json(part, json)
        rescue
          raise PathError, "Expected #{json.class}\nto be an object with property #{part}"
        end
      end
      if type == '*'
        case json.class.name
        when 'Array'
          expect_all(json, &block)
        when 'Hash'
          json.each do |k,v|
            yield json[k]
          end
        end
      elsif type == '?'
        expect_one(path, json, &block)
      else
        yield json
      end
    end

    def ensure_array_or_hash(path, json)
      fail RSpec::Expectations::ExpectationNotMetError, "Expected #{path} to be array or hash, got #{json.class} from JSON response" unless
        json.class == Array || json.class == Hash
    end
  end
end