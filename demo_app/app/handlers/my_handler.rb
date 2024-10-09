# frozen_string_literal: true

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  {
    statusCode: 200,
    body: {
      message: 'Hello World',
      event: event
    }.to_json
  }
end
