# frozen_string_literal: true

require 'bauble'

app = Bauble::Application.new(
  name: 'basic-bauble-app',
  code_dir: 'app'
)

role = Bauble::Resources::LambdaRole.new(
  app,
  name: 'lambda-role'
)

Bauble::Resources::RubyFunction.new(
  app,
  role: role,
  name: 'hello-world',
  handler: 'app/hello_world.handler'
)
