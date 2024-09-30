# frozen_string_literal: true

require 'httparty'
require_relative 'models/post'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts event.to_json
  HTTParty.get('https://jsonplaceholder.typicode.com/posts/1')
  Post.find(id: 'hi').to_h.to_json
end
