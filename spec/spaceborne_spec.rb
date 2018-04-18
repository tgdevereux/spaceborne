require 'spec_helper'

describe Spaceborne do
  include Spaceborne
  TRELLO_BOARD_ID = '555c8e81e8d5aff570505f5b'

  it 'has a version number' do
    expect(Spaceborne::VERSION).not_to be nil
  end

  it "does a simple get" do
    get 'http://example.com', {Accept: 'json'}
    expect_status(200)
  end

  it "trello API no key or token" do
    wrap_request do
      get "https://api.trello.com/1/boards/#{TRELLO_BOARD_ID}"
      expect_status(200)
      expect_header(content_type: 'application/json; charset=utf-8')
      expect_header_types('set_cookie.*', :string )
      expect_json(labelNames: {green: 'michelle greenz'})
      expect_json_types('labelNames.*', :string)
    end
  end

  it "trello API lists - array check" do
    wrap_request do
      get "https://api.trello.com/1/boards/#{TRELLO_BOARD_ID}/lists"
      expect_status(200)
      expect_header(content_type: 'application/json; charset=utf-8')
      expect_header_types('set_cookie.*', :string )
      expect_json('*', id: /^[0-9a-f]{24}$/)
      expect_json_types('*', id: :string)
    end
  end

end
