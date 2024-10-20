# frozen_string_literal: true

describe Bauble::Resources::SQSQueue do
  let(:app) { instance_double(Bauble::Application, name: 'test_app', current_stack: double(name: 'test_stack')) }
  let(:queue_name) { 'test-queue' }
  let(:dead_letter_queue) { instance_double(Bauble::Resources::SQSQueue, name: 'dlq') }

  before do
    allow(app).to receive(:add_resource)
  end

  describe '#initialize' do
    it 'sets attributes correctly and adds itself to the app resources' do
      queue = described_class.new(app, name: queue_name, visibility_timeout: 60, message_retention: 86_400,
                                       dead_letter_queue: dead_letter_queue)
      expect(queue.name).to eq(queue_name)
      expect(queue.visibility_timeout).to eq(60)
      expect(queue.message_retention).to eq(86_400)
      expect(queue.dead_letter_queue).to eq(dead_letter_queue)
      expect(app).to have_received(:add_resource).with(queue)
    end

    it 'uses default values when optional parameters are not provided' do
      queue = described_class.new(app, name: queue_name)
      expect(queue.visibility_timeout).to eq(30)
      expect(queue.message_retention).to eq(345_600)
      expect(queue.dead_letter_queue).to be_nil
    end
  end

  describe '#synthesize' do
    it 'returns the correct structure without a dead letter queue' do
      queue = described_class.new(app, name: queue_name)
      expected_structure = {
        queue_name => {
          'type' => 'aws:sqs:Queue',
          'properties' => {
            'name' => queue.resource_name(queue_name),
            'visibilityTimeoutSeconds' => 30,
            'messageRetentionSeconds' => 345_600
          }
        }
      }

      expect(queue.synthesize).to eq(expected_structure)
    end

    it 'returns the correct structure with a dead letter queue' do
      queue = described_class.new(app, name: queue_name, dead_letter_queue: dead_letter_queue)
      expected_structure = {
        queue_name => {
          'type' => 'aws:sqs:Queue',
          'properties' => {
            'name' => queue.resource_name(queue_name),
            'visibilityTimeoutSeconds' => 30,
            'messageRetentionSeconds' => 345_600
          }
        },
        'redrivePolicy' => {
          'type' => 'aws:sqs:RedrivePolicy',
          'properties' => {
            'queueUrl' => "${#{queue_name}}",
            'redrivePolicy' => {
              'deadLetterTargetArn' => "${#{dead_letter_queue.name}.arn}",
              'maxReceiveCount' => 5
            }.to_json
          }
        }
      }

      expect(queue.synthesize).to eq(expected_structure)
    end
  end

  describe '#add_target' do
    let(:function) { instance_double('Function', name: 'test-function', role: instance_double('Role')) }

    before do
      allow(function.role).to receive(:add_policy_statement)
    end

    it 'adds a lambda target to the queue' do
      queue = described_class.new(app, name: queue_name)
      queue.add_target(function)

      expected_target = {
        "#{queue_name}_to_#{function.name}" => {
          'type' => 'aws:lambda:EventSourceMapping',
          'properties' => {
            'eventSourceArn' => "${#{queue_name}.arn}",
            'functionName' => "${#{function.name}.name}",
            'batchSize' => 10
          }
        }
      }

      expect(queue.synthesize).to include(expected_target)
      expect(function.role).to have_received(:add_policy_statement).with(
        effect: 'Allow',
        actions: ['sqs:ReceiveMessage', 'sqs:DeleteMessage', 'sqs:GetQueueAttributes'],
        resources: ["${#{queue_name}.arn}"]
      )
    end
  end

  describe '#bundle' do
    it 'returns true' do
      queue = described_class.new(app, name: queue_name)
      expect(queue.bundle).to be true
    end
  end
end
