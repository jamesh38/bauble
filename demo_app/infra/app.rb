# frozen_string_literal: true

require 'bauble'
require 'pry'
require 'pry-byebug'

RubyFunction = Bauble::Resources::RubyFunction
LambdaRole = Bauble::Resources::LambdaRole
ApiGatewayV2 = Bauble::Resources::ApiGatewayV2

app = Bauble::Application.new(name: 'myapp', code_dir: 'app', skip_gem_layer: true)

Bauble::Resources::S3Bucket.new(app, bucket_name: 'mybucket', force_destroy: true)

# role = LambdaRole.new(
#   app,
#   role_name: 'myrole',
#   policy_statements: [
#     {
#       effect: 'allow',
#       actions: ['dynamodb:GetItem'],
#       resources: ['*']
#     }
#   ]
# )

# fun = RubyFunction.new(
#   app,
#   name: 'myfunction',
#   handler: 'app/handlers/hello_world.handler',
#   role: role
# )

# fun2 = RubyFunction.new(
#   app,
#   name: 'function-two',
#   handler: 'app/handlers/my_handler.handler',
#   role: role
# )

# api = ApiGatewayV2.new(app, name: 'myapi')

# api.add_route(route_key: 'GET /hello', function: fun)
# api.add_route(route_key: 'GET /world', function: fun2)
