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

rule = Bauble::Resources::EventBridgeRule.new(
  app,
  rule_name: 'myrule',
  event_pattern: {
    source: ['custom-source'],
    'detail-type': ['hello-world']
  }
)

rule.add_target(fun)
