# frozen_string_literal: true

require_relative 'resource'

# Bauble resources to manage infrastructure
module Bauble
  module Resources
    # SQS Queue
    class SQSQueue < Resource
      attr_accessor :name, :visibility_timeout, :lambda_targets, :message_retention, :dead_letter_queue,
                    :encryption, :encryption_master_key

      def initialize(app, **kwargs)
        super(app)
        @name = kwargs.fetch(:name)
        @visibility_timeout = kwargs.fetch(:visibility_timeout, 30)
        @message_retention = kwargs.fetch(:message_retention, 345_600)
        @dead_letter_queue = kwargs.fetch(:dead_letter_queue, nil)
        @content_based_deduplication = kwargs.fetch(:content_based_deduplication, false)
        @lambda_targets = []
      end

      def synthesize
        base_template = {
          @name => {
            'type' => 'aws:sqs:Queue',
            'properties' => {
              'name' => resource_name(@name),
              'visibilityTimeoutSeconds' => @visibility_timeout,
              'messageRetentionSeconds' => @message_retention
            }.compact
          }
        }

        base_template.merge!(dead_letter_queue_template) if @dead_letter_queue

        @lambda_targets.each { |target| base_template.merge!(target) }

        base_template
      end

      def bundle
        true
      end

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

      private

      def dead_letter_queue_template
        {
          'redrivePolicy' => {
            'type' => 'aws:sqs:RedrivePolicy',
            'properties' => {
              'queueUrl' => "${#{name}}",
              'redrivePolicy' => {
                'deadLetterTargetArn' => "${#{@dead_letter_queue.name}.arn}",
                'maxReceiveCount' => 5
              }.to_json
            }
          }
        }
      end
    end
  end
end
