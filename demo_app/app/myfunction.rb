# frozen_string_literal: true

require 'httparty'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts event.to_json
  HTTParty.get('https://jsonplaceholder.typicode.com/posts/1')
end
