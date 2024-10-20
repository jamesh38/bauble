# frozen_string_literal: true

require 'bauble/cli/bundle_command_builder'

describe Bauble::Cli::BundleCommandBuilder do
  describe '#initialize' do
    it 'initializes with an empty commands array' do
      builder = described_class.new
      expect(builder.build).to eq('')
    end
  end

  describe '#with_bundle_without' do
    it 'adds the bundle config set without command with the specified groups' do
      builder = described_class.new.with_bundle_without(%w[test development])
      expect(builder.build).to include('bundle config set without test development')
    end
  end

  describe '#with_bundle_path' do
    it 'adds the bundle config set path command with the specified path' do
      builder = described_class.new.with_bundle_path('/my/custom/path')
      expect(builder.build).to include('bundle config set path /my/custom/path')
    end
  end

  describe '#with_bauble_gem_override' do
    it 'adds the bundle config local.bauble_core command' do
      builder = described_class.new.with_bauble_gem_override
      expect(builder.build).to include('bundle config local.bauble_core /var/task/bauble_core')
    end
  end

  describe '#with_bundle_install' do
    it 'adds the bundle install command' do
      builder = described_class.new.with_bundle_install
      expect(builder.build).to include('bundle install')
    end
  end

  describe '#with_dot_bundle_cleanup' do
    it 'adds the rm -rf .bundle command' do
      builder = described_class.new.with_dot_bundle_cleanup
      expect(builder.build).to include('rm -rf .bundle')
    end
  end

  describe '#build' do
    it 'builds the complete bundle command chain' do
      builder = described_class.new
                               .with_bundle_without(%w[test development])
                               .with_bundle_path('/my/custom/path')
                               .with_bauble_gem_override
                               .with_bundle_install
                               .with_dot_bundle_cleanup

      expected_command = 'bundle config set without test development && ' \
                         'bundle config set path /my/custom/path && ' \
                         'bundle config local.bauble_core /var/task/bauble_core && ' \
                         'bundle install && ' \
                         'rm -rf .bundle'

      expect(builder.build).to eq(expected_command)
    end
  end
end
