# frozen_string_literal: true

describe Bauble::Stack do
  let(:app) { instance_double(Bauble::Application) }
  let(:stack_name) { 'test_stack' }

  before do
    allow(app).to receive(:add_stack)
  end

  describe '#initialize' do
    it 'sets the name attribute correctly' do
      stack = described_class.new(app, stack_name)
      expect(stack.name).to eq(stack_name)
    end

    it 'adds itself to the application stacks' do
      stack = described_class.new(app, stack_name)
      expect(app).to have_received(:add_stack).with(stack)
    end
  end
end
