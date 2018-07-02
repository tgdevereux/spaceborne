require 'spec_helper'

include Spaceborne

describe Spaceborne do
  it "returns a version" do
    expect(Spaceborne::VERSION).to match(/[^.]+\.[^.]+\.[^.]$/)
  end
  it "ensure_array_or_hash" do
    expect(ensure_array_or_hash('root', [])).to be nil
    expect(ensure_array_or_hash('root', {})).to be nil
    expect{ensure_array_or_hash('root', 'string')}.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
  it "is_json detects json headers" do
    expect(is_json?(content_type: 'application/json')).to eq(true)
    expect(is_json?(content_type: 'application/text')).to eq(false)
  end
  specify { expect { wrap_request do
                       mock_get('spaceborne_readme_1')
                       get '/spaceborne_readme_1', {}
                       expect_status(200)
                       expect_json(name: 'Alexandra')
                     end }.to raise_error(RSpec::Expectations::ExpectationNotMetError).and output.to_stdout }
  specify { expect { wrap_request do
                       mock_get('spaceborne_readme_1', {content_type: 'application/json'})
                       get '/spaceborne_readme_1'
                       expect_status(200)
                       expect_json(name: 'Alexandra')
                     end }.to raise_error(RSpec::Expectations::ExpectationNotMetError).and output.to_stdout }

  context "readme examples" do
    it "expectations working for first json response" do
      mock_get('spaceborne_readme_1')
      get '/spaceborne_readme_1', {}
      expect_json(name: 'Alex') # exact match because you asked for Alex
      expect_json_types(name: :string, address: {street: :string, city: :string, state: :string,
                                                 coordinates: {latitude: :float, longitude: :float}},
                        phones: :array_of_objects) # all the types and structure (cannot go into arrays this way)
      expect_json('address', state: /^[A-Z]{2}$/) # ensures address/state has 2 capital letters
      expect_json_types('phones.*', type: :string, number: :string) # looks at all elements in array
      expect_json_types('phones.1', type: :string, number: :string) # looks at second element in array
      expect_json_keys('address', [:street, :city, :state, :coordinates]) # ensure specified keys present
      expect_json_sizes(phones: 2) # expect the phones array size to be 2
    end
    it "expectations working for second json response" do
      mock_get('spaceborne_readme_2')
      get '/spaceborne_readme_2'
      expect_json_types('array_of_hashes.*.*', first: :string, last: :string)
      expect_json_types('hash_of_hashes.*', first: :string, last: :string)
    end
  end
  it "header expectations follow spaceborne format" do
    mock_get('spaceborne_readme_2', {foo: 'bar'})
    get '/spaceborne_readme_2'
    expect_header(foo: 'bar')
    expect_header_types(foo: :string)
  end
  it "use_proxy" do
    mock_get('spaceborne_readme_2', {use_proxy: 'bar'})
    get '/spaceborne_readme_2', {use_proxy: 'bar'}
    expect_header(use_proxy: 'bar')
  end
  it "nonjson_data" do
    mock_post('spaceborne_readme_2')
    post '/spaceborne_readme_2', {foo: 'bar'}, {nonjson_data: true}
    expect_header(nonjson_data: nil)
    expect_header(content_type: nil)
  end  
end
