require 'spec_helper'
require 'byebug'

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

  it "Get", todos: true do
    wrap_request do
      get "#{SIMPLE_URL}/todos", {}
      expect_status(200)
      expect_header(content_type: 'application/json; charset=utf-8')
    end
  end
  it "Post w json", todos: true do
    wrap_request do
      post "#{SIMPLE_URL}/todos", { title: 'Learn Elm', created_by: '1' },
        {}
      expect_status(201)
      expect_header(content_type: 'application/json; charset=utf-8')
    end
  end
  it "Post w nonjson", todos: true do
    wrap_request do
      post "#{SIMPLE_URL}/todos", { title: 'Learn Elm', created_by: '1' },
        {nonjson_data: true}
      expect_status(201)
      expect_header(content_type: 'application/json; charset=utf-8')
    end
  end
  it "get of particular todo", todos: true do
    wrap_request do
      get 'http://localhost:3000/todos/3'
      expect_status(200)
      expect_json(title: 'do_not_delete')
      expect_json_types(id: :integer, title: :string, created_by: :string,
        created_at: :date, updated_at: :date)
    end
  end
  it "Put w bad data", todos: true do
    wrap_request do
      put "http://localhost:3000/todos/3", {bad_data: 'oops'}
      expect_status(204)
    end
  end
  it "validates the cases in the readme" do
    fake = {name: "Alex",
            address: {
              street: "Area 51",
              city: "Roswell",
              state: "NM",
              coordinates: {
                latitude: 33.3872,
                longitude: 104.5281 } },
            phones: [
              { type: "cell",
                number: "123-456-7890"},
              { type: "home",
                number: "987-654-3210"} ]}
    expect_json_fake(fake, name: 'Alex') # exact match because you asked for Alex
    expect_json_types_fake(fake, name: :string, address: {street: :string, city: :string, state: :string,
                                               coordinates: {latitude: :float, longitude: :float}},
                      phones: :array_of_objects) # all the types and structure (note cannot specify array checking)
    expect_json_fake(fake, 'address', state: /^[A-Z]{2}$/) # ensures address/state has 2 capital letters
    expect_json_types_fake(fake, 'phones.*', type: :string, number: :string) # looks at all elements in array
    expect_json_types_fake(fake, 'phones.1', type: :string, number: :string) # looks at second element in array
    expect_json_keys_fake(fake, [:name, :address, :phones])
    expect_json_keys_fake(fake, 'address', [:street, :city, :state, :coordinates])
    expect_json_sizes_fake(fake, phones: 2)
  end
end
