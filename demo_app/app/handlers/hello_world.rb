# frozen_string_literal: true

require 'net/http'
require 'json'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts event.to_json
  uri = URI('https://jsonplaceholder.typicode.com/todos/2')
  res = Net::HTTP.get_response(uri)
  { statusCode: 200, body: res.body }
end
