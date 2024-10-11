# frozen_string_literal: true

require 'bauble'
require 'pry'
require 'pry-byebug'

RubyFunction = Bauble::Resources::RubyFunction
LambdaRole = Bauble::Resources::LambdaRole
ApiGatewayV2 = Bauble::Resources::ApiGatewayV2

app = Bauble::Application.new(name: 'myapp', code_dir: 'app')

role = LambdaRole.new(
  app,
  name: 'myrole'
)

my_func = RubyFunction.new(
  app,
  name: 'myfunction',
  handler: 'app/handlers/hello_world.handler',
  role: role
)

my_rule = Bauble::Resources::EventBridgeRule.new(
  app,
  name: 'my-rule',
  event_pattern: {
    source: ['custom-source'],
    'detail-type': ['custom-detail-type']
  }
)

my_rule.add_target(my_func)
