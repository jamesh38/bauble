# frozen_string_literal: true

require 'bauble/cli/code_bundler'
require 'stringio'

describe Bauble::Cli::CodeBundler do
  let(:gem_path) { '.bauble/assets/gem_layer' }
  let(:docker_command) { 'docker build command' }
  let(:bundle_command) { 'bundle install command' }
  let(:docker_builder) { instance_double(Bauble::Cli::DockerCommandBuilder) }
  let(:bundle_builder) { instance_double(Bauble::Cli::BundleCommandBuilder) }

  before do
    allow(Bauble::Cli::DockerCommandBuilder).to receive(:new).and_return(docker_builder)
    allow(docker_builder).to receive(:with_rm).and_return(docker_builder)
    allow(docker_builder).to receive(:with_volume).and_return(docker_builder)
    allow(docker_builder).to receive(:with_workdir).and_return(docker_builder)
    allow(docker_builder).to receive(:with_entrypoint).and_return(docker_builder)
    allow(docker_builder).to receive(:with_platform).and_return(docker_builder)
    allow(docker_builder).to receive(:with_image).and_return(docker_builder)
    allow(docker_builder).to receive(:with_command).and_return(docker_builder)
    allow(docker_builder).to receive(:build).and_return(docker_command)

    allow(Bauble::Cli::BundleCommandBuilder).to receive(:new).and_return(bundle_builder)
    allow(bundle_builder).to receive(:with_bundle_without).and_return(bundle_builder)
    allow(bundle_builder).to receive(:with_bundle_path).and_return(bundle_builder)
    allow(bundle_builder).to receive(:with_bauble_gem_override).and_return(bundle_builder)
    allow(bundle_builder).to receive(:with_bundle_install).and_return(bundle_builder)
    allow(bundle_builder).to receive(:with_dot_bundle_cleanup).and_return(bundle_builder)
    allow(bundle_builder).to receive(:build).and_return(bundle_command)

    allow(Bauble::Cli::Logger).to receive(:docker)
    allow(Bauble::Cli::Logger).to receive(:error)

    allow(IO).to receive(:popen).and_yield(StringIO.new("Docker output line\n"))
    allow_any_instance_of(described_class).to receive(:`).with('rm -rf .bundle')
  end

  describe '.docker_bundle_gems' do
    context 'when the docker command succeeds' do
      before do
        allow(described_class).to receive(:last_process_success?).and_return(true)
      end

      it 'logs docker output and does not log an error' do
        described_class.docker_bundle_gems(gem_path: gem_path)

        expect(Bauble::Cli::Logger).to have_received(:docker).with("Docker output line\n")
        expect(Bauble::Cli::Logger).not_to have_received(:error)
      end
    end

    context 'when the docker command fails' do
      before do
        allow(described_class).to receive(:last_process_success?).and_return(false)
      end

      it 'logs an error, removes the bundle, and exits' do
        expect(Bauble::Cli::Logger).to receive(:error).with('Bundle step failed')
        expect(described_class).to receive(:`).with('rm -rf .bundle')
        expect { described_class.docker_bundle_gems(gem_path: gem_path) }.to raise_error(SystemExit)
      end
    end
  end

  describe '.docker_build_gems_command' do
    it 'builds the correct docker command' do
      result = described_class.send(:docker_build_gems_command, gem_path)

      expect(docker_builder).to have_received(:with_rm)
      expect(docker_builder).to have_received(:with_volume).with('$(pwd):/var/task')
      expect(docker_builder).to have_received(:with_workdir).with('/var/task')
      expect(docker_builder).to have_received(:with_entrypoint).with('/bin/sh')
      expect(docker_builder).to have_received(:with_platform).with('linux/amd64')
      expect(docker_builder).to have_received(:with_image).with('public.ecr.aws/sam/build-ruby3.2')
      expect(docker_builder).to have_received(:with_command).with(bundle_command)
      expect(result).to eq(docker_command)
    end

    context 'when BAUBLE_DEV_GEM_PATH is set' do
      before do
        ENV['BAUBLE_DEV_GEM_PATH'] = '/mocked/path'
      end

      after do
        ENV.delete('BAUBLE_DEV_GEM_PATH')
      end

      it 'includes the volume for the dev gem path' do
        described_class.send(:docker_build_gems_command, gem_path)
        expect(docker_builder).to have_received(:with_volume).with('/mocked/path:/var/task/bauble_core')
      end
    end
  end

  describe '.bundle_command' do
    it 'builds the correct bundle command' do
      result = described_class.send(:bundle_command, gem_path)

      expect(bundle_builder).to have_received(:with_bundle_without).with(%w[test development])
      expect(bundle_builder).to have_received(:with_bundle_path).with(gem_path)
      expect(bundle_builder).to have_received(:with_bundle_install)
      expect(bundle_builder).to have_received(:with_dot_bundle_cleanup)
      expect(result).to eq(bundle_command)
    end

    context 'when BAUBLE_DEV_GEM_PATH is set' do
      before do
        ENV['BAUBLE_DEV_GEM_PATH'] = '/mocked/path'
      end

      after do
        ENV.delete('BAUBLE_DEV_GEM_PATH')
      end

      it 'includes the bauble gem override' do
        described_class.send(:bundle_command, gem_path)
        expect(bundle_builder).to have_received(:with_bauble_gem_override)
      end
    end
  end
end
