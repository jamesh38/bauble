# frozen_string_literal: true

describe Bauble::Resources::RubyFunction do
  let(:role) { instance_double('Role', name: 'test-role') }
  let(:app) do
    instance_double(
      Bauble::Application,
      name: 'test_app',
      current_stack: double(name: 'test_stack'),
      config: double(asset_dir: '.bauble/assets', shared_code_hash: 'mocked_shared_code', skip_gem_layer: false),
      shared_code_hash: 'mocked_shared_code'
    )
  end

  before do
    allow(app).to receive(:add_resource)
  end

  describe '#initialize' do
    it 'sets attributes correctly and adds itself to the app resources' do
      function = described_class.new(
        app,
        name: 'test-function',
        handler: 'app.handler',
        role: role,
        timeout: 60,
        memory_size: 256,
        env_vars: { 'ENV_VAR' => 'value' },
        reserved_concurrent_executions: 5,
        vpc_config: { subnet_ids: ['subnet-123'], security_group_ids: ['sg-123'] },
        function_url: true
      )

      expect(function.name).to eq('test-function')
      expect(function.handler).to eq('app.handler')
      expect(function.role).to eq(role)
      expect(function.timeout).to eq(60)
      expect(function.memory_size).to eq(256)
      expect(function.env_vars).to include('ENV_VAR' => 'value')
      expect(function.reserved_concurrent_executions).to eq(5)
      expect(function.vpc_config).to eq({ subnet_ids: ['subnet-123'], security_group_ids: ['sg-123'] })
      expect(function.function_url).to be true
      expect(app).to have_received(:add_resource).with(function)
    end

    it 'uses default values when optional parameters are not provided' do
      function = described_class.new(app, name: 'test-function', handler: 'app.handler', role: role)

      expect(function.timeout).to eq(30)
      expect(function.memory_size).to eq(128)
      expect(function.env_vars).to eq({})
      expect(function.reserved_concurrent_executions).to be_nil
      expect(function.vpc_config).to be_nil
      expect(function.function_url).to be false
    end
  end

  describe '#synthesize' do
    it 'returns the correct structure without a VPC configuration or function URL' do
      function = described_class.new(app, name: 'test-function', handler: 'app.handler', role: role)

      expected_structure = {
        'test-function' => {
          'type' => 'aws:lambda:Function',
          'name' => function.resource_name('test-function'),
          'properties' => {
            'name' => function.resource_name('test-function'),
            'handler' => 'app.handler',
            'runtime' => 'ruby3.2',
            'code' => {
              'fn::fileArchive' => "#{app.config.asset_dir}/shared_app_code/#{app.shared_code_hash}"
            },
            'role' => "${#{role.name}.arn}",
            'layers' => ['${gemLayer.arn}'],
            'environment' => {
              'variables' => {
                'GEM_PATH' => '/opt/ruby/3.2.0'
              }
            },
            'timeout' => 30,
            'memorySize' => 128
          }
        }
      }

      expect(function.synthesize).to eq(expected_structure)
    end

    it 'returns the correct structure with a VPC configuration' do
      function = described_class.new(
        app,
        name: 'test-function',
        handler: 'app.handler',
        role: role,
        vpc_config: { subnet_ids: %w[subnet-123 subnet-456], security_group_ids: %w[sg-123 sg-456] }
      )

      expected_structure = {
        'test-function' => {
          'type' => 'aws:lambda:Function',
          'name' => function.resource_name('test-function'),
          'properties' => {
            'name' => function.resource_name('test-function'),
            'handler' => 'app.handler',
            'runtime' => 'ruby3.2',
            'code' => {
              'fn::fileArchive' => "#{app.config.asset_dir}/shared_app_code/#{app.shared_code_hash}"
            },
            'role' => "${#{role.name}.arn}",
            'layers' => ['${gemLayer.arn}'],
            'environment' => {
              'variables' => {
                'GEM_PATH' => '/opt/ruby/3.2.0'
              }
            },
            'timeout' => 30,
            'memorySize' => 128,
            'vpcConfig' => {
              'subnetIds' => %w[subnet-123 subnet-456],
              'securityGroupIds' => %w[sg-123 sg-456]
            }
          }
        }
      }

      expect(function.synthesize).to eq(expected_structure)
    end

    it 'returns the correct structure with a function URL' do
      function = described_class.new(
        app,
        name: 'test-function',
        handler: 'app.handler',
        role: role,
        function_url: true
      )

      expected_structure = {
        'test-function' => {
          'type' => 'aws:lambda:Function',
          'name' => function.resource_name('test-function'),
          'properties' => {
            'name' => function.resource_name('test-function'),
            'handler' => 'app.handler',
            'runtime' => 'ruby3.2',
            'code' => {
              'fn::fileArchive' => "#{app.config.asset_dir}/shared_app_code/#{app.shared_code_hash}"
            },
            'role' => "${#{role.name}.arn}",
            'layers' => ['${gemLayer.arn}'],
            'environment' => {
              'variables' => {
                'GEM_PATH' => '/opt/ruby/3.2.0'
              }
            },
            'timeout' => 30,
            'memorySize' => 128
          }
        },
        'function_url' => {
          'type' => 'aws:lambda:FunctionUrl',
          'name' => 'test-functionUrl',
          'properties' => {
            'functionName' => '${test-function}',
            'authorizationType' => 'NONE'
          }
        }
      }

      expect(function.synthesize).to eq(expected_structure)
    end
  end

  describe '#bundle' do
    it 'returns true' do
      function = described_class.new(app, name: 'test-function', handler: 'app.handler', role: role)
      expect(function.bundle).to be true
    end
  end
end
