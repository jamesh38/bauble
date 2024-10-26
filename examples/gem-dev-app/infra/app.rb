# frozen_string_literal: true

require 'bauble'
require 'pry'

Bauble::Application.new(
  name: 'MyApp',
  code_dir: 'app'
)
