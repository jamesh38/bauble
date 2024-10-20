# frozen_string_literal: true

require 'bauble/cli/logger'

describe Bauble::Cli::Logger do
  let(:output) { StringIO.new }

  around do |example|
    original_stdout = $stdout
    $stdout = output
    example.run
    $stdout = original_stdout
  end

  before do
    # Set the environment variable for debug mode
    allow(ENV).to receive(:[]).with('BAUBLE_DEBUG').and_return('true')
  end

  describe '.log' do
    it 'prints a green message with [ Bauble ] prefix' do
      described_class.log('Test message')
      expect(output.string).to include('[ Bauble ] Test message'.green)
    end
  end

  describe '.block_log' do
    it 'prints a message with newlines before and after' do
      described_class.block_log('Block log message')
      expect(output.string).to eq("\n#{'[ Bauble ] Block log message'.green}\n")
    end
  end

  describe '.pulumi' do
    it 'prints a blue message with [ Pulumi ] prefix' do
      described_class.pulumi('Pulumi message')
      expect(output.string).to include('[ Pulumi ] Pulumi message'.blue)
    end
  end

  describe '.docker' do
    it 'prints a magenta message with [ Docker ] prefix' do
      described_class.docker('Docker message')
      expect(output.string).to include('[ Docker ] Docker message'.magenta)
    end
  end

  describe '.nl' do
    it 'prints a single newline by default' do
      described_class.nl
      expect(output.string).to eq("\n")
    end

    it 'prints multiple newlines when specified' do
      described_class.nl(3)
      expect(output.string).to eq("\n\n\n")
    end
  end

  describe '.debug' do
    context 'when BAUBLE_DEBUG is set' do
      it 'prints a yellow debug message' do
        described_class.debug('Debug message')
        expect(output.string).to include('[ Bauble DEBUG ] Debug message'.yellow)
      end
    end

    context 'when BAUBLE_DEBUG is not set' do
      before do
        allow(ENV).to receive(:[]).with('BAUBLE_DEBUG').and_return(nil)
      end

      it 'does not print the debug message' do
        described_class.debug('Debug message')
        expect(output.string).to be_empty
      end
    end
  end

  describe '.error' do
    it 'prints a red error message with newlines before and after' do
      described_class.error('Error message')
      expect(output.string).to eq("\n#{'[ Bauble Error ] Error message'.red}\n\n")
    end
  end

  describe '.logo' do
    it 'prints the logo' do
      described_class.logo
      expect(output.string).to include(Bauble::VERSION)
    end
  end
end
