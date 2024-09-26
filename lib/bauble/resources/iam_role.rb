# frozen_string_literal: true

require_relative 'base_resource'

# Lambda role
module Bauble
  module Resources
    # aws lambda role
    class IamRole < BaseResource
      attr_accessor :role_name, :policies

      def initialize(app, role_name:, policies: [])
        super(app)
        @role_name = role_name
        @policies = policies
      end

      def synthesize
        {
          @role_name => {
            'type' => 'aws:iam:Role',
            'properties' => {
              'assumeRolePolicy' => assume_role_policy
            }
          }
        }
      end

      def assume_role_policy
        <<-POLICY
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow"
          }
        ]
      }
        POLICY
      end
    end
  end
end
