# frozen_string_literal: true

require_relative '../models/post'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts event.to_json
  puts 'HET!!'
  post = Post.find(id: 'hi').to_h
  { statusCode: 200, body: { post: post }.to_json }
end
