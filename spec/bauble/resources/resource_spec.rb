# frozen_string_literal: true

describe Bauble::Resources::Resource do
  let(:app) { instance_double(Bauble::Application, name: 'test_app', current_stack: double(name: 'test_stack')) }

  before do
    allow(app).to receive(:add_resource)
  end

  describe '#initialize' do
    it 'sets the app attribute and adds itself to the app resources' do
      resource = described_class.new(app)
      expect(resource.app).to eq(app)
      expect(app).to have_received(:add_resource).with(resource)
    end
  end

  describe '#synthesize' do
    it 'raises a not implemented error' do
      resource = described_class.new(app)
      expect { resource.synthesize }.to raise_error('Not implemented')
    end
  end

  describe '#bundle' do
    it 'raises a not implemented error' do
      resource = described_class.new(app)
      expect { resource.bundle }.to raise_error('Not implemented')
    end
  end

  describe '#resource_name' do
    it 'returns the correct resource name' do
      resource = described_class.new(app)
      expect(resource.resource_name('my-resource')).to eq('test_app-my-resource-test_stack')
    end
  end
end
