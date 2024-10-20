# frozen_string_literal: true

require 'bauble/cli/docker_command_builder'

describe Bauble::Cli::DockerCommandBuilder do
  describe '#initialize' do
    it 'initializes with the base docker run command' do
      builder = described_class.new
      expect(builder.build).to eq('docker run')
    end
  end

  describe '#with_rm' do
    it 'adds the --rm flag to the command' do
      builder = described_class.new.with_rm
      expect(builder.build).to include('--rm')
    end
  end

  describe '#with_volume' do
    it 'adds the volume flag to the command' do
      builder = described_class.new.with_volume('/host/path:/container/path')
      expect(builder.build).to include('-v /host/path:/container/path')
    end
  end

  describe '#with_workdir' do
    it 'adds the workdir flag to the command' do
      builder = described_class.new.with_workdir('/app')
      expect(builder.build).to include('-w /app')
    end
  end

  describe '#with_entrypoint' do
    it 'adds the entrypoint flag to the command' do
      builder = described_class.new.with_entrypoint('/bin/bash')
      expect(builder.build).to include('--entrypoint /bin/bash')
    end
  end

  describe '#with_platform' do
    it 'adds the platform flag to the command' do
      builder = described_class.new.with_platform('linux/amd64')
      expect(builder.build).to include('--platform linux/amd64')
    end
  end

  describe '#with_image' do
    it 'adds the image to the command' do
      builder = described_class.new.with_image('my-image:latest')
      expect(builder.build).to include('my-image:latest')
    end
  end

  describe '#with_command' do
    it 'adds the command to the docker run command' do
      builder = described_class.new.with_command('echo "hello world"')
      expect(builder.build).to include('-c "echo \\"hello world\\""')
    end
  end

  describe '#with_env' do
    it 'adds an environment variable to the command' do
      builder = described_class.new.with_env('MY_VAR', 'my_value')
      expect(builder.build).to include('-e MY_VAR=my_value')
    end
  end

  describe '#build' do
    it 'builds the complete docker run command' do
      builder = described_class.new
                               .with_rm
                               .with_volume('/host/path:/container/path')
                               .with_workdir('/app')
                               .with_entrypoint('/bin/bash')
                               .with_platform('linux/amd64')
                               .with_image('my-image:latest')
                               .with_command('echo "hello world"')
                               .with_env('MY_VAR', 'my_value')

      expected_command = 'docker run --rm -v /host/path:/container/path -w /app --entrypoint /bin/bash ' \
                         '--platform linux/amd64 my-image:latest -c "echo \\"hello world\\"" -e MY_VAR=my_value'
      expect(builder.build).to eq(expected_command)
    end
  end
end
