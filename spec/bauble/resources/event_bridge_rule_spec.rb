# frozen_string_literal: true

describe Bauble::Resources::EventBridgeRule do
  let(:app) { instance_double(Bauble::Application, name: 'test_app', current_stack: double(name: 'test_stack')) }
  let(:rule_name) { 'test-rule' }

  before do
    allow(app).to receive(:add_resource)
  end

  describe '#initialize' do
    it 'sets the name, description, and event bus name correctly' do
      rule = described_class.new(app, name: rule_name, description: 'Test rule', event_bus_name: 'custom-bus',
                                      schedule_expression: '5 minutes')
      expect(rule.instance_variable_get(:@name)).to eq(rule_name)
      expect(rule.instance_variable_get(:@description)).to eq('Test rule')
      expect(rule.instance_variable_get(:@event_bus_name)).to eq('custom-bus')
    end

    it 'uses default values when optional parameters are not provided' do
      rule = described_class.new(app, name: rule_name, event_pattern: { source: ['aws.ec2'] })
      expect(rule.instance_variable_get(:@description)).to eq('Bauble EventBridge Rule')
      expect(rule.instance_variable_get(:@event_bus_name)).to eq('default')
      expect(rule.instance_variable_get(:@state)).to eq('ENABLED')
    end

    it 'adds itself to the application resources' do
      rule = described_class.new(app, name: rule_name, event_pattern: { source: ['aws.ec2'] })
      expect(app).to have_received(:add_resource).with(rule)
    end

    it 'raises an error if no name is provided' do
      expect do
        described_class.new(app, name: nil, event_pattern: { source: ['aws.ec2'] })
      end.to raise_error('EventBridgeRule must have a name')
    end

    it 'raises an error if neither event_pattern nor schedule_expression is provided' do
      expect do
        described_class.new(app, name: rule_name)
      end.to raise_error('EventBridgeRule must have an event_pattern or a schedule_expression')
    end

    it 'raises an error if both event_pattern and schedule_expression are provided' do
      expect do
        described_class.new(app, name: rule_name, event_pattern: { source: ['aws.ec2'] },
                                 schedule_expression: 'rate(5 minutes)')
      end.to raise_error('EventBridgeRule cannot have both an event_pattern and a schedule_expression')
    end
  end

  describe '#synthesize' do
    it 'returns the correct rule structure with event pattern' do
      event_pattern = { source: ['aws.ec2'] }
      rule = described_class.new(app, name: rule_name, event_pattern: event_pattern)
      expected_structure = {
        rule_name => {
          'type' => 'aws:cloudwatch:EventRule',
          'properties' => {
            'name' => rule.resource_name(rule_name),
            'description' => 'Bauble EventBridge Rule',
            'eventBusName' => 'default',
            'state' => 'ENABLED',
            'eventPattern' => event_pattern.to_json
          }
        }
      }

      expect(rule.synthesize).to eq(expected_structure)
    end

    it 'returns the correct rule structure with schedule expression' do
      schedule_expression = 'rate(5 minutes)'
      rule = described_class.new(app, name: rule_name, schedule_expression: schedule_expression)
      expected_structure = {
        rule_name => {
          'type' => 'aws:cloudwatch:EventRule',
          'properties' => {
            'name' => rule.resource_name(rule_name),
            'description' => 'Bauble EventBridge Rule',
            'eventBusName' => 'default',
            'state' => 'ENABLED',
            'scheduleExpression' => schedule_expression
          }
        }
      }

      expect(rule.synthesize).to eq(expected_structure)
    end
  end

  describe '#add_target' do
    let(:function) { double('Function', name: 'test-function') }

    it 'adds a target to the rule' do
      rule = described_class.new(app, name: rule_name, event_pattern: { source: ['aws.ec2'] })
      rule.add_target(function)

      expected_target = {
        "#{rule_name}-#{function.name}-target" => {
          'type' => 'aws:cloudwatch:EventTarget',
          'properties' => {
            'rule' => "${#{rule_name}.name}",
            'arn' => "${#{function.name}.arn}"
          }
        },
        "#{function.name}-permission" => {
          'type' => 'aws:lambda:Permission',
          'properties' => {
            'action' => 'lambda:InvokeFunction',
            'function' => "${#{function.name}.name}",
            'principal' => 'events.amazonaws.com',
            'sourceArn' => "${#{rule_name}.arn}"
          }
        }
      }

      expect(rule.synthesize).to include(expected_target)
    end
  end

  describe '#bundle' do
    it 'returns true' do
      rule = described_class.new(app, name: rule_name, event_pattern: { source: ['aws.ec2'] })
      expect(rule.bundle).to be true
    end
  end
end
