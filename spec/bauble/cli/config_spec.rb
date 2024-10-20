# frozen_string_literal: true

require 'bauble/cli/config'

describe Bauble::Cli::Config do
  describe '#initialize' do
    let(:config) { described_class.new }

    it 'sets the root directory to the current working directory' do
      expect(config.root_dir).to eq(Dir.pwd)
    end

    it 'sets the bauble_home directory based on the root directory' do
      expect(config.bauble_home).to eq("#{Dir.pwd}/.bauble")
    end

    it 'sets the asset directory based on the bauble_home directory' do
      expect(config.asset_dir).to eq("#{Dir.pwd}/.bauble/assets")
    end

    it 'sets the pulumi_home directory based on the bauble_home directory' do
      expect(config.pulumi_home).to eq("#{Dir.pwd}/.bauble/.pulumi")
    end

    it 'sets the gem layer asset directory based on the asset directory' do
      expect(config.gem_layer_asset_dir).to eq("#{Dir.pwd}/.bauble/assets/gem_layer")
    end

    it 'sets the shared code asset directory based on the asset directory' do
      expect(config.shared_code_asset_dir).to eq("#{Dir.pwd}/.bauble/assets/shared_app_code")
    end

    it 'sets the app stack name to the default value "bauble"' do
      expect(config.app_stack_name).to eq('bauble')
    end

    it 'sets the debug flag based on the BAUBLE_DEBUG environment variable' do
      expect(config.debug).to eq(ENV['BAUBLE_DEBUG'] || false)
    end

    it 'sets the skip_gem_layer flag to false by default' do
      expect(config.skip_gem_layer).to be(false)
    end

    it 'sets Pulumi-related environment variables' do
      expect(ENV['PULUMI_HOME']).to eq(config.pulumi_home)
      expect(ENV['PULUMI_CONFIG_PASSPHRASE']).to eq('')
      expect(ENV['PULUMI_SKIP_UPDATE_CHECK']).to eq('true')
    end
  end

  describe '.configure' do
    it 'yields a new configuration instance and returns it' do
      described_class.configure do |config|
        expect(config).to be_an_instance_of(described_class)
        config.app_name = 'test_app'
        expect(config.app_name).to eq('test_app')
      end
    end

    it 'returns a configured instance' do
      config = described_class.configure do |c|
        c.app_name = 'configured_app'
      end

      expect(config.app_name).to eq('configured_app')
    end
  end
end
