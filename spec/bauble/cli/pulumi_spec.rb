# frozen_string_literal: true

require 'bauble/cli/pulumi'

describe Bauble::Cli::Pulumi do
  let(:config) do
    instance_double(
      'Config',
      pulumi_home: '/mocked/pulumi_home',
      debug: false
    )
  end
  let(:pulumi) { described_class.new(config: config) }

  before do
    allow(Bauble::Cli::Logger).to receive(:debug)
    allow(Bauble::Cli::Logger).to receive(:pulumi)
    allow(Bauble::Cli::Logger).to receive(:nl)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:write)
    allow(IO).to receive(:popen).and_return(double(read: '', each: []))
    allow(pulumi).to receive(:run_command).and_return('')
    allow(pulumi).to receive(:pulumi_command_success?).and_return(true)
    allow(config).to receive(:s3_backend)
  end

  describe '#create_pulumi_yml' do
    it 'creates Pulumi.yaml in the specified directory' do
      template = 'pulumi_template_content'

      pulumi.create_pulumi_yml(template)

      expect(Bauble::Cli::Logger).to have_received(:debug).with('Creating Pulumi.yaml...')
      expect(FileUtils).to have_received(:mkdir_p).with('/mocked/pulumi_home')
      expect(File).to have_received(:write).with('/mocked/pulumi_home/Pulumi.yaml', template, mode: 'w')
    end
  end

  describe '#init!' do
    context 'when pulumi is not initialized' do
      before do
        allow(pulumi).to receive(:pulumi_initialized?).and_return(false)
        allow(pulumi).to receive(:init_pulumi)
      end

      it 'initializes pulumi' do
        pulumi.init!
        expect(pulumi).to have_received(:init_pulumi)
      end
    end

    context 'when pulumi is already initialized' do
      before do
        allow(pulumi).to receive(:pulumi_initialized?).and_return(true)
        allow(pulumi).to receive(:init_pulumi)
      end

      it 'does not initialize pulumi again' do
        pulumi.init!
        expect(pulumi).not_to have_received(:init_pulumi)
      end
    end
  end

  describe '#preview' do
    it 'runs pulumi preview' do
      allow(pulumi).to receive(:output_command)

      pulumi.preview

      expect(pulumi).to have_received(:output_command).with('preview')
      expect(Bauble::Cli::Logger).to have_received(:debug).with("Running pulumi preview...\n")
    end
  end

  describe '#up' do
    it 'runs pulumi up without target' do
      allow(pulumi).to receive(:output_command)

      pulumi.up

      expect(pulumi).to have_received(:output_command).with('up --yes')
      expect(Bauble::Cli::Logger).to have_received(:debug).with("Running pulumi up...\n")
    end

    it 'runs pulumi up with a specific target' do
      allow(pulumi).to receive(:output_command)

      pulumi.up('my-target')

      expect(pulumi).to have_received(:output_command).with('up --yes --target my-target')
      expect(Bauble::Cli::Logger).to have_received(:debug).with("Running pulumi up...\n")
    end
  end

  describe '#destroy' do
    it 'runs pulumi destroy' do
      allow(pulumi).to receive(:output_command)

      pulumi.destroy

      expect(pulumi).to have_received(:output_command).with('destroy --yes')
      expect(Bauble::Cli::Logger).to have_received(:debug).with("Running pulumi destroy...\n")
    end
  end

  describe '#create_or_select_stack' do
    before do
      allow(pulumi).to receive(:stack_initialized?).and_return(false)
      allow(pulumi).to receive(:init_stack)
      allow(pulumi).to receive(:select_stack)
    end

    it 'initializes a new stack if it does not exist' do
      pulumi.create_or_select_stack('test-stack')
      expect(pulumi).to have_received(:init_stack).with('test-stack')
      expect(pulumi).not_to have_received(:select_stack)
    end

    it 'selects an existing stack if it exists' do
      allow(pulumi).to receive(:stack_initialized?).and_return(true)
      pulumi.create_or_select_stack('test-stack')
      expect(pulumi).to have_received(:select_stack).with('test-stack')
      expect(pulumi).not_to have_received(:init_stack)
    end
  end

  describe '#pulumi_yml_exists?' do
    it 'checks for the existence of Pulumi.yaml' do
      allow(File).to receive(:exist?).with('/mocked/pulumi_home/Pulumi.yaml').and_return(true)

      pulumi.send(:pulumi_yml_exists?)

      expect(File).to have_received(:exist?).with('/mocked/pulumi_home/Pulumi.yaml').at_least(:once)
      expect(Bauble::Cli::Logger).to have_received(:debug).with('Checking for Pulumi.yaml... true')
    end
  end

  describe '#pulumi_logged_in?' do
    it 'checks if the user is logged into pulumi' do
      allow(pulumi).to receive(:run_command).with('whoami')

      pulumi.send(:pulumi_logged_in?)

      expect(pulumi).to have_received(:run_command).with('whoami')
      expect(Bauble::Cli::Logger).to have_received(:debug).with('Checking pulumi login status... true')
    end
  end

  describe '#stack_initialized?' do
    it 'checks if a stack is initialized' do
      allow(pulumi).to receive(:run_command).with('stack ls').and_return('test-stack')

      pulumi.send(:stack_initialized?, 'test-stack')

      expect(Bauble::Cli::Logger).to have_received(:debug).with('Checking if stack test-stack is initialized...')
    end
  end

  describe '#init_stack' do
    it 'initializes a stack with the correct name' do
      allow(pulumi).to receive(:run_command)

      pulumi.send(:init_stack, 'test-stack')

      expect(pulumi).to have_received(:run_command).with('stack init --stack test-stack')
    end
  end

  describe '#select_stack' do
    it 'selects a stack with the correct name' do
      allow(pulumi).to receive(:run_command)

      pulumi.send(:select_stack, 'test-stack')

      expect(pulumi).to have_received(:run_command).with('stack select --stack test-stack')
    end
  end

  describe '#login' do
    it 'logs into pulumi locally' do
      allow(pulumi).to receive(:run_command)

      pulumi.send(:login)

      expect(pulumi).to have_received(:run_command).with('login --local')
      expect(Bauble::Cli::Logger).to have_received(:debug).with('Logging into pulumi locally...')
    end

    it 'logs into pulumi with s3 backend' do
      allow(pulumi).to receive(:run_command)
      allow(config).to receive(:s3_backend).and_return('s3://my-bucket')

      pulumi.send(:login)

      expect(pulumi).to have_received(:run_command).with('login')
      expect(Bauble::Cli::Logger).to have_received(:debug).with('Logging into pulumi locally...')
    end
  end
end
