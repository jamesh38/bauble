# frozen_string_literal: true

require 'bauble'
require 'pry'
require 'pry-byebug'

app = Bauble::Application.new(name: 'myapp', code_dir: 'app')

role = Bauble::Resources::IamRole.new(
  app,
  role_name: 'myrole',
  policies: [
    {
      effect: 'allow',
      actions: ['dynamodb:GetItem'],
      resources: ['*']
    }
  ]
)

Bauble::Resources::RubyFunction.new(
  app,
  name: 'myfunction',
  handler: 'app/myfunction.handler',
  role: role
)

Bauble::Resources::RubyFunction.new(
  app,
  name: 'myfunction2',
  handler: 'app/myfunction.handler',
  role: role
)

Bauble::Resources::RubyFunction.new(
  app,
  name: 'myfunction3',
  handler: 'app/myfunction.handler',
  role: role
)
