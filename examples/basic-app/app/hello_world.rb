# frozen_string_literal: true

require 'httparty'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  response = HTTParty.get('https://api.chucknorris.io/jokes/random')
  joke = JSON.parse(response.body)['value']
  puts joke
end
