require 'spec_helper'

describe 'client requester' do
  before do
    allow(RestClient).to receive(:send)
    RSpec::Mocks.space.proxy_for(self).remove_stub_if_present(:get)
  end

  after do
    allow(RestClient).to receive(:send).and_call_original
    Airborne.configure { |config| config.headers = {} }
  end

  it 'should set :Content-Type to :json by default' do
    get '/foo'

    expect(RestClient).to have_received(:send)
      .with(:get, 'http://www.example.com/foo',
            "Content-Type" => 'application/json',
            no_restclient_headers: true)
  end

  it 'should override headers with option[:headers]' do
    get '/foo', "Content-Type" => 'application/x-www-form-urlencoded'

    expect(RestClient)
      .to have_received(:send)
      .with(:get, 'http://www.example.com/foo',
            "Content-Type" => 'application/x-www-form-urlencoded',
            no_restclient_headers: true)
  end

  it 'should override headers with airborne config headers' do
    Airborne.configure { |config| config.headers = { "Content-Type" => 'text/plain' } }

    get '/foo'

    expect(RestClient)
      .to have_received(:send)
      .with(:get, 'http://www.example.com/foo',
            "Content-Type" => 'text/plain',
            no_restclient_headers: true)
  end
end
