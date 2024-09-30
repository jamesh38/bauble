# frozen_string_literal: true

require_relative 'base_resource'

# Lambda role
module Bauble
  module Resources
    # aws lambda role
    # TODO: this should probably be lambda role no IAM role. do we need an IAM Role resource?
    class IamRole < BaseResource
      attr_accessor :role_name, :policies

      def initialize(app, role_name:, policies: [])
        super(app)
        @role_name = role_name
        @policies = policies
      end

      def synthesize
        role_hash = {
          role_name => {
            'type' => 'aws:iam:Role',
            'properties' => {
              'assumeRolePolicy' => assume_role_policy
            }
          }
        }

        return role_hash.merge(role_policy) if @policies.any?

        role_hash
      end

      def bundle
        true
      end

      private

      def role_policy
        {
          "#{role_name}-policy" => {
            'type' => 'aws:iam:RolePolicy',
            'properties' => {
              'name' => "#{role_name}-policy",
              'role' => "${#{role_name}}",
              'policy' => synth_policies
            }
          }
        }
      end

      def synth_policies
        {
          Version: '2012-10-17',
          Statement: @policies.map do |policy|
            {
              Effect: policy[:effect].downcase == 'allow' ? 'Allow' : 'Deny',
              Action: policy[:actions],
              Resource: policy[:resources]
            }
          end
        }.to_json
      end

      def assume_role_policy
        {
          'Version' => '2012-10-17',
          'Statement' => [
            {
              'Action' => 'sts:AssumeRole',
              'Principal' => {
                'Service' => 'lambda.amazonaws.com'
              },
              'Effect' => 'Allow'
            }
          ]
        }.to_json
      end
    end
  end
end
