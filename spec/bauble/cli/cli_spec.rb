# frozen_string_literal: true

require 'bauble/cli/cli'
require 'thor'
require 'fileutils'

describe Bauble::Cli::BaubleCli do
  let(:app) { instance_double(Bauble::Application, name: 'test_app', skip_gem_layer: false, config: nil) }
  let(:config) do
    instance_double(
      Bauble::Cli::Config,
      pulumi_home: '/mocked/pulumi_home'
    )
  end
  let(:pulumi) { instance_double(Bauble::Cli::Pulumi) }
  let(:bauble_json_content) { { 'entrypoint' => 'entrypoint_file.rb' }.to_json }

  before do
    allow(ObjectSpace).to receive(:each_object).with(Bauble::Application).and_return([app].each)
    allow(Bauble::Cli::Config).to receive(:configure).and_yield(config).and_return(config)
    allow(config).to receive(:app_name=)
    allow(config).to receive(:skip_gem_layer=)
    allow(config).to receive(:s3_backend=)
    allow(File).to receive(:read).with('bauble.json').and_return(bauble_json_content)
    allow(File).to receive(:exist?).with('bauble.json').and_return(true)
    allow(JSON).to receive(:parse).with(bauble_json_content).and_return(JSON.parse(bauble_json_content))
    allow(Bauble::Cli::Pulumi).to receive(:new).and_return(pulumi)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:open)
    allow(app).to receive(:config=)
    allow(app).to receive(:s3_backend)
    allow(Kernel).to receive(:require).with("#{Dir.pwd}/entrypoint_file.rb")
  end

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be(true)
    end
  end

  describe '#pulumi' do
    it 'returns a Pulumi instance' do
      cli = described_class.new

      expect(cli.send(:pulumi)).to eq(pulumi)
    end

    it 'memoizes the Pulumi instance' do
      cli = described_class.new

      expect(Bauble::Cli::Pulumi).to receive(:new).once.and_return(pulumi)
      cli.send(:pulumi)
      cli.send(:pulumi)
    end
  end

  describe '#build_config' do
    it 'configures the application config' do
      cli = described_class.new

      cli.send(:setup_app)
      cli.send(:build_config)

      # `configure` might be called twice, once during initialization and again explicitly.
      expect(Bauble::Cli::Config).to have_received(:configure).twice
      expect(config).to have_received(:app_name=).with('test_app').twice
      expect(config).to have_received(:skip_gem_layer=).with(false).twice
      expect(app).to have_received(:config=).with(config).twice
    end
  end

  describe '#write_stack_template' do
    let(:stack) { double(name: 'test-stack', template: 'stack_template_content') }

    it 'creates the necessary directory and writes the stack template file' do
      cli = described_class.new

      expect(FileUtils).to receive(:mkdir_p).with('/mocked/pulumi_home')
      expect(File).to receive(:write).with('/mocked/pulumi_home/Pulumi.test-stack.yaml', 'stack_template_content')
      cli.send(:setup_app)

      cli.send(:write_stack_template, stack)
    end
  end

  describe '#create_directory' do
    it 'creates the pulumi home directory' do
      cli = described_class.new

      expect(FileUtils).to receive(:mkdir_p).with('/mocked/pulumi_home')
      cli.send(:setup_app)

      cli.send(:create_directory)
    end
  end

  describe '#bauble_json' do
    it 'parses and memoizes the bauble.json content' do
      cli = described_class.new

      # Call the method for the first time
      cli.send(:setup_app)
      cli.send(:bauble_json)

      # Ensure `JSON.parse` is called once during the first call
      expect(JSON).to have_received(:parse).once

      # Call the method again to verify that it is memoized
      expect(cli.send(:bauble_json)).to eq({ 'entrypoint' => 'entrypoint_file.rb' })
    end
  end

  describe '#require_entrypoint' do
    it 'requires the entrypoint defined in bauble.json' do
      cli = described_class.new
      cli.send(:setup_app)

      expect(Kernel).to have_received(:require).with("#{Dir.pwd}/entrypoint_file.rb")
    end
  end
end
