# frozen_string_literal: true

describe Bauble::Resources::LambdaRole do
  let(:app) { instance_double(Bauble::Application, name: 'test_app', current_stack: double(name: 'test_stack')) }
  let(:role_name) { 'test-role' }
  let(:policy_statements) { [{ effect: 'Allow', actions: ['s3:PutObject'], resources: ['*'] }] }

  before do
    allow(app).to receive(:add_resource)
  end

  describe '#initialize' do
    it 'sets the name, policy_statements, and description correctly' do
      role = described_class.new(app, name: role_name, policy_statements: policy_statements, description: 'Test role')
      expect(role.name).to eq(role_name)
      expect(role.policy_statements).to eq(policy_statements)
      expect(role.description).to eq('Test role')
    end

    it 'uses default description when none is provided' do
      role = described_class.new(app, name: role_name)
      expect(role.description).to eq('Bauble lambda role')
    end

    it 'initializes with an empty array for managed_policy_arns' do
      role = described_class.new(app, name: role_name)
      expect(role.managed_policy_arns).to eq([])
    end

    it 'adds itself to the application resources' do
      role = described_class.new(app, name: role_name)
      expect(app).to have_received(:add_resource).with(role)
    end
  end

  describe '#synthesize' do
    it 'returns the correct role structure without policies' do
      role = described_class.new(app, name: role_name)
      expected_structure = {
        role_name => {
          'type' => 'aws:iam:Role',
          'properties' => {
            'name' => role.resource_name(role_name),
            'assumeRolePolicy' => role.send(:assume_role_policy),
            'managedPolicyArns' => [
              'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
            ],
            'description' => 'Bauble lambda role'
          }
        }
      }

      expect(role.synthesize).to eq(expected_structure)
    end

    it 'returns the correct role structure with policies' do
      role = described_class.new(app, name: role_name, policy_statements: policy_statements)
      expected_structure = {
        role_name => {
          'type' => 'aws:iam:Role',
          'properties' => {
            'name' => role.resource_name(role_name),
            'assumeRolePolicy' => role.send(:assume_role_policy),
            'managedPolicyArns' => [
              'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
            ],
            'description' => 'Bauble lambda role'
          }
        },
        "#{role_name}-policy" => {
          'type' => 'aws:iam:RolePolicy',
          'properties' => {
            'name' => "#{role_name}-policy",
            'role' => "${#{role_name}}",
            'policy' => role.send(:synth_policies)
          }
        }
      }

      expect(role.synthesize).to eq(expected_structure)
    end
  end

  describe '#add_policy_statement' do
    it 'adds a policy statement to the policy_statements array' do
      role = described_class.new(app, name: role_name)
      role.add_policy_statement(effect: 'Allow', actions: ['s3:GetObject'],
                                resources: ['arn:aws:s3:::example-bucket/*'])
      expect(role.policy_statements).to include(
        effect: 'Allow',
        actions: ['s3:GetObject'],
        resources: ['arn:aws:s3:::example-bucket/*']
      )
    end
  end

  describe '#bundle' do
    it 'returns true' do
      role = described_class.new(app, name: role_name)
      expect(role.bundle).to be true
    end
  end
end
