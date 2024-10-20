# frozen_string_literal: true

describe Bauble::Resources::ApiGatewayV2 do
  let(:app) do
    instance_double(
      Bauble::Application,
      name: 'test_app',
      current_stack: double(name: 'test_stack')
    )
  end
  let(:function) { instance_double('Function', name: 'test-function') }

  before do
    allow(app).to receive(:add_resource)
  end

  describe '#initialize' do
    it 'sets attributes correctly and adds itself to the app resources' do
      api_gateway = described_class.new(app, name: 'test-api')

      expect(api_gateway.name).to eq('test-api')
      expect(api_gateway.routes).to be_empty
      expect(app).to have_received(:add_resource).with(api_gateway)
    end
  end

  describe '#synthesize' do
    it 'returns the correct structure with no routes' do
      api_gateway = described_class.new(app, name: 'test-api')

      expected_structure = {
        'test-api' => {
          'type' => 'aws:apigatewayv2:Api',
          'properties' => {
            'name' => api_gateway.resource_name('test-api'),
            'protocolType' => 'HTTP'
          }
        },
        'test-api-stage' => {
          'type' => 'aws:apigatewayv2:Stage',
          'properties' => {
            'apiId' => '${test-api.id}',
            'name' => app.current_stack.name,
            'autoDeploy' => true
          }
        },
        'test-api-deployment' => {
          'type' => 'aws:apigatewayv2:Deployment',
          'properties' => {
            'apiId' => '${test-api.id}'
          },
          'options' => {
            'dependsOn' => []
          }
        }
      }

      expect(api_gateway.synthesize).to eq(expected_structure)
    end

    it 'returns the correct structure with a route' do
      api_gateway = described_class.new(app, name: 'test-api')
      api_gateway.add_route(route_key: 'GET /test', function: function)

      expected_structure = {
        'test-api' => {
          'type' => 'aws:apigatewayv2:Api',
          'properties' => {
            'name' => api_gateway.resource_name('test-api'),
            'protocolType' => 'HTTP'
          }
        },
        'test-api-stage' => {
          'type' => 'aws:apigatewayv2:Stage',
          'properties' => {
            'apiId' => '${test-api.id}',
            'name' => app.current_stack.name,
            'autoDeploy' => true
          }
        },
        'test-api-route-0' => {
          'type' => 'aws:apigatewayv2:Route',
          'properties' => {
            'apiId' => '${test-api.id}',
            'routeKey' => 'GET /test',
            'target' => 'integrations/${test-api-route-0-integration.id}'
          }
        },
        'test-api-route-0-integration' => {
          'type' => 'aws:apigatewayv2:Integration',
          'properties' => {
            'apiId' => '${test-api.id}',
            'integrationUri' => '${test-function.arn}',
            'integrationType' => 'AWS_PROXY',
            'payloadFormatVersion' => '2.0'
          }
        },
        'test-function-api-gateway-permission' => {
          'type' => 'aws:lambda:Permission',
          'properties' => {
            'action' => 'lambda:InvokeFunction',
            'function' => '${test-function.name}',
            'principal' => 'apigateway.amazonaws.com',
            'sourceArn' => '${test-api.executionArn}/*/*'
          }
        },
        'test-api-deployment' => {
          'type' => 'aws:apigatewayv2:Deployment',
          'properties' => {
            'apiId' => '${test-api.id}'
          },
          'options' => {
            'dependsOn' => ['${test-api-route-0}', '${test-api-route-0-integration}']
          }
        }
      }

      expect(api_gateway.synthesize).to eq(expected_structure)
    end
  end

  describe '#add_route' do
    it 'adds a route to the API Gateway' do
      api_gateway = described_class.new(app, name: 'test-api')
      api_gateway.add_route(route_key: 'GET /test', function: function)

      expect(api_gateway.routes).to include(
        route_key: 'GET /test',
        target_lambda_arn: "${#{function.name}.arn}",
        function_name: function.name
      )
    end
  end

  describe '#bundle' do
    it 'returns true' do
      api_gateway = described_class.new(app, name: 'test-api')
      expect(api_gateway.bundle).to be true
    end
  end
end
