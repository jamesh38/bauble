# frozen_string_literal: true

require_relative 'resource'

# bauble resources to manage infrastructure
module Bauble
  module Resources
    # SQS Queue
    class SQSQueue < Resource
      attr_accessor :name, :visibility_timeout, :lambda_targets

      def initialize(app, name:, visibility_timeout: 30)
        super(app)
        @name = name
        @visibility_timeout = visibility_timeout
        @lambda_targets = []
      end

      def synthesize
        base_template = {
          @name => {
            'type' => 'aws:sqs:Queue',
            'properties' => {
              'name' => @name,
              'visibilityTimeoutSeconds' => @visibility_timeout
            }
          }
        }

        @lambda_targets.each { |target| base_template.merge!(target) }

        base_template
      end

      def bundle
        true
      end

      # Function to add a Lambda function as a target to the SQS Queue
      def add_target(function)
        @lambda_targets << {
          "#{@name}_to_#{function.name}" => {
            'type' => 'aws:lambda:EventSourceMapping',
            'properties' => {
              'eventSourceArn' => "${#{name}.arn}",
              'functionName' => "${#{function.name}.name}",
              'batchSize' => 10
            }
          }
        }
        function.role.add_policy_statement(
          effect: 'Allow',
          actions: ['sqs:ReceiveMessage', 'sqs:DeleteMessage', 'sqs:GetQueueAttributes'],
          resources: ["${#{name}.arn}"]
        )
      end
    end
  end
end
