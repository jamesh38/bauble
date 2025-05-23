# frozen_string_literal: true

require_relative 'bauble/version'
require_relative 'bauble/application'
require_relative 'bauble/resources/lambda_role'
require_relative 'bauble/resources/s3_bucket'
require_relative 'bauble/resources/ruby_function'
require_relative 'bauble/resources/gem_layer'
require_relative 'bauble/resources/event_bridge_rule'
require_relative 'bauble/resources/sqs_queue'
require_relative 'bauble/resources/api_gateway_v2'
require_relative 'bauble/stack'

module Bauble
  class Error < StandardError; end
end
