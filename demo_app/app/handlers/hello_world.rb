# frozen_string_literal: true

require_relative '../models/post'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts event.to_json
  puts 'HET!!'
  Post.find(id: 'hi').to_h.to_json
end
