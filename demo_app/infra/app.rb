# frozen_string_literal: true

require 'bauble'
require 'pry'
require 'pry-byebug'

app = Bauble::Application.new(name: 'myapp')

role = Bauble::Resources::IamRole.new(app, role_name: 'myrole')

Bauble::Resources::RubyFunction.new(
  app,
  name: 'myfunction',
  handler: 'app/myfunction.handler',
  code_dir: 'app',
  role: role
)
