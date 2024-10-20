# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter 'lib/bauble/resources/postgres_layer.rb'
  track_files '{lib}/**/*.rb'
end

require 'bauble'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.expose_dsl_globally = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
