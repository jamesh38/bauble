# frozen_string_literal: true

require 'bauble'
require 'pry'
require 'pry-byebug'

RubyFunction = Bauble::Resources::RubyFunction
LambdaRole = Bauble::Resources::LambdaRole
ApiGatewayV2 = Bauble::Resources::ApiGatewayV2
S3Bucket = Bauble::Resources::S3Bucket

app = Bauble::Application.new(
  name: 'myapp',
  code_dir: 'app',
  skip_gem_layer: true
)

# Create a role
role = LambdaRole.new(
  app,
  name: 'myrole'
)

# Create a function
my_func = RubyFunction.new(
  app,
  name: 'myfunction',
  handler: 'app/handlers/hello_world.handler',
  role: role,
  image_uri: '723551696986.dkr.ecr.us-east-2.amazonaws.com/my-repo:adsf',
  timeout: 60,
  memory_size: 256,
  env_vars: {
    HELLO: 'WORLD'
  }
)

# Create an event bridge rule
my_rule = Bauble::Resources::EventBridgeRule.new(
  app,
  name: 'my-rule',
  event_pattern: {
    source: ['custom-source'],
    'detail-type': ['custom-detail-type']
  }
)
my_rule.add_target(my_func)

# Create an API Gateway v2
my_api = ApiGatewayV2.new(app, name: 'my-api')
my_api.add_route(route_key: 'GET /hello', function: my_func)

# Create an SQS Queue
dlq = Bauble::Resources::SQSQueue.new(app, name: 'my-dlq-queue')
my_queue = Bauble::Resources::SQSQueue.new(
  app,
  name: 'my-queue',
  dead_letter_queue: dlq,
  visibility_timeout: 60,
  message_retention: 120
)
my_queue.add_target(my_func)

S3Bucket.new(app, name: 'my-bucket')
