# frozen_string_literal: true

require_relative 'resource'

# Api Gateway v2
module Bauble
  module Resources
    # AWS API Gateway v2
    class ApiGatewayV2 < Resource
      attr_accessor :name, :routes, :app

      def initialize(app, name:)
        super(app)
        @app = app
        @name = name
        @routes = []
      end

      def synthesize
        base_hash = api_hash
        base_hash.merge!(routes_hash)
        base_hash.merge!(deploymeny_hash)
        base_hash.merge!(synthesize_permissions)
        base_hash
      end

      def add_route(route_key:, function:)
        routes << { route_key: route_key, target_lambda_arn: "${#{function.name}.arn}", function_name: function.name }
      end

      def bundle
        true
      end

      private

      def routes_hash
        routes.each_with_index.each_with_object({}) do |(route, index), route_hash|
          route_name = "#{name}-route-#{index}"
          route_hash[route_name] = {
            'type' => 'aws:apigatewayv2:Route',
            'properties' => {
              'apiId' => "${#{name}.id}",
              'routeKey' => route[:route_key],
              'target' => "integrations/${#{route_name}-integration.id}"
            }
          }
          route_hash.merge!(integration_hash(route, route_name))
        end
      end

      def integration_hash(route, route_name)
        {
          "#{route_name}-integration" => {
            'type' => 'aws:apigatewayv2:Integration',
            'properties' => {
              'apiId' => "${#{name}.id}",
              'integrationUri' => route[:target_lambda_arn],
              'integrationType' => 'AWS_PROXY',
              'payloadFormatVersion' => '2.0'
            }
          }
        }
      end

      def synthesize_permissions
        routes.uniq { |route| route[:function_name] }.each_with_object({}) do |route, permissions_hash|
          permissions_hash.merge!(function_permission_hash(route[:function_name]))
        end
      end

      def function_permission_hash(function_name)
        {
          "#{function_name}-api-gateway-permission" => {
            'type' => 'aws:lambda:Permission',
            'properties' => {
              'action' => 'lambda:InvokeFunction',
              'function' => "${#{function_name}.name}",
              'principal' => 'apigateway.amazonaws.com',
              'sourceArn' => "${#{name}.executionArn}/*/*"
            }
          }
        }
      end

      def deploymeny_hash
        {
          "#{name}-deployment" => {
            'type' => 'aws:apigatewayv2:Deployment',
            'properties' => {
              'apiId' => "${#{name}.id}"
            },
            'options' => {
              'dependsOn' => routes_hash.keys.map { |route_name| "${#{route_name}}" }
            }
          }
        }
      end

      def api_hash
        {
          name => {
            'type' => 'aws:apigatewayv2:Api',
            'properties' => {
              'name' => resource_name(name),
              'protocolType' => 'HTTP'
            }
          },
          "#{name}-stage" => {
            'type' => 'aws:apigatewayv2:Stage',
            'properties' => {
              'apiId' => "${#{name}.id}",
              'name' => app.current_stack.name,
              'autoDeploy' => true
            }
          }
        }
      end
    end
  end
end
