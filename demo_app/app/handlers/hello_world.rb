# frozen_string_literal: true

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts event.to_json
end
