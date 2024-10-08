# frozen_string_literal: true

require 'bauble'
require 'pry'
require 'pry-byebug'

app = Bauble::Application.new(name: 'myapp', code_dir: 'app')

role = Bauble::Resources::LambdaRole.new(
  app,
  role_name: 'myrole',
  policy_statements: [
    {
      effect: 'allow',
      actions: ['dynamodb:GetItem'],
      resources: ['*']
    }
  ]
)

fun = Bauble::Resources::RubyFunction.new(
  app,
  name: 'myfunction',
  handler: 'app/handlers/hello_world.handler',
  role: role
)

queue = Bauble::Resources::SQSQueue.new(app, name: 'my-queue')
queue.add_lambda_target(fun)
