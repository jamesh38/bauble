# frozen_string_literal: true

require_relative 'resource'

# Lambda role
module Bauble
  module Resources
    # aws lambda role
    class LambdaRole < Resource
      attr_accessor :name, :policy_statements

      def initialize(app, name:, policy_statements: [])
        super(app)
        @name = name
        @policy_statements = policy_statements
      end

      def synthesize
        role_hash = {
          name => {
            'type' => 'aws:iam:Role',
            'properties' => {
              'name' => resource_name(name),
              'assumeRolePolicy' => assume_role_policy,
              'managedPolicyArns' => ['arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole']
            }
          }
        }

        return role_hash.merge(role_policy) if policy_statements.any?

        role_hash
      end

      def add_policy_statement(effect:, actions:, resources:)
        policy_statements << { effect: effect, actions: actions, resources: resources }
      end

      def bundle
        true
      end

      private

      def role_policy
        {
          "#{name}-policy" => {
            'type' => 'aws:iam:RolePolicy',
            'properties' => {
              'name' => "#{name}-policy",
              'role' => "${#{name}}",
              'policy' => synth_policies
            }
          }
        }
      end

      def synth_policies
        {
          Version: '2012-10-17',
          Statement: policy_statements.map do |statement|
            {
              Effect: statement[:effect].downcase == 'allow' ? 'Allow' : 'Deny',
              Action: statement[:actions],
              Resource: statement[:resources]
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
