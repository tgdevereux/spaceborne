require 'spec_helper'

describe Spaceborne do
  include Spaceborne
  SIMPLE_URL = 'http://localhost:3000'
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

  it "Get" do
    wrap_request do
      get "#{SIMPLE_URL}/todos", {}
      expect_status(200)
      expect_header(content_type: 'application/json; charset=utf-8')
    end
  end
  it "Post w json" do
    wrap_request do
      post "#{SIMPLE_URL}/todos", { title: 'Learn Elm', created_by: '1' },
        {}
      expect_status(201)
      expect_header(content_type: 'application/json; charset=utf-8')
    end
  end
  it "Post w nonjson" do
    wrap_request do
      post "#{SIMPLE_URL}/todos", { title: 'Learn Elm', created_by: '1' },
        {nonjson_data: true}
      expect_status(201)
      expect_header(content_type: 'application/json; charset=utf-8')
    end
  end
  it "get of particular todo" do
    wrap_request do
      get 'http://localhost:3000/todos/3'
      expect_status(200)
      expect_json(title: 'do_not_delete')
      expect_json_types(id: :integer, title: :string, created_by: :string,
        created_at: :date, updated_at: :date)
    end
  end
  it "Put w bad data" do
    wrap_request do
      put "http://localhost:3000/todos/3", {bad_data: 'oops'}
      expect_status(204)
    end
  end
end