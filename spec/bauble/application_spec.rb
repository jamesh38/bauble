# frozen_string_literal: true

describe Bauble::Application do
  describe '#initialize' do
    it 'initializes with minimal args' do
      app = described_class.new(name: 'my-app', code_dir: 'app')
      expect(app.name).to eq 'my-app'
    end

    it 'initializes with minimal args with gem layer' do
      app = described_class.new(name: 'my-app', code_dir: 'app')
      expect(app.resources.length).to eq 1
      expect(app.resources.first).to be_instance_of Bauble::Resources::GemLayer
    end

    it 'initializes with minimal args with dev stack' do
      app = described_class.new(name: 'my-app', code_dir: 'app')
      expect(app.stacks[0].name).to eq 'dev'
    end

    it 'initializes with stacks' do
      app = described_class.new(
        name: 'my-app',
        code_dir: 'app',
        stacks: %w[dev stag]
      )
      expect(app.stacks.count).to eq 2
    end

    it 'initializes with skipping gem layer' do
      app = described_class.new(name: 'my-app', code_dir: 'app', skip_gem_layer: true)
      expect(app.resources.length).to eq 0
    end

    it 'initializes with current stack' do
      app = described_class.new(name: 'my-app', code_dir: 'app', stacks: %w[dev staging])
      expect(app.current_stack.name).to eq 'dev'
    end
  end

  describe '#add_resource' do
    it 'adds a resource' do
      app = described_class.new(name: 'my-app', code_dir: 'app')
      app.add_resource(Bauble::Resources::S3Bucket.new(app, name: 'my-bucket'))
      expect(app.resources.count).to eq 3
    end
  end

  describe '#add_stack' do
    it 'adds a stack' do
      app = described_class.new(name: 'my-app', code_dir: 'app')
      app.add_stack('staging')
      expect(app.stacks.count).to eq 2
    end
  end

  describe '#change_current_stack' do
    it 'changes the current stack' do
      app = described_class.new(name: 'my-app', code_dir: 'app', stacks: %w[dev staging])
      expect(app.current_stack.name).to eq 'dev'
      app.change_current_stack('staging')
      expect(app.current_stack.name).to eq 'staging'
    end

    it 'logs error and exits when stack doesnt exist' do
      expect_any_instance_of(Object).to receive(:exit).with(1)
      expect(Bauble::Cli::Logger).to receive(:error).with('Unknown stack stag')
      app = described_class.new(name: 'my-app', code_dir: 'app', stacks: %w[dev staging])
      expect(app.current_stack.name).to eq 'dev'
      app.change_current_stack('stag')
    end
  end

  describe '#bundle' do
    let(:name) { 'test_app' }
    let(:code_dir) { 'code_dir' }
    let(:stacks) { ['test_stack'] }
    let(:application) { described_class.new(name: name, code_dir: code_dir, stacks: stacks) }

    before do
      # Stubbing file and directory operations
      allow(Dir).to receive(:pwd).and_return('/mocked/path')
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp_r)
      expect_any_instance_of(Bauble::Resources::GemLayer).to receive(:bundle)

      # Stubbing methods for directory and file hash computation
      allow(Dir).to receive(:glob).and_return(['/mocked/path/code_dir/file1.rb', '/mocked/path/code_dir/file2.rb'])
      allow(File).to receive(:file?).and_return(true)
      allow(Digest::SHA256).to receive(:file).and_return(double(hexdigest: 'mocked_hash'))

      # Stubbing configuration access
      config = double(
        'Config',
        root_dir: '/mocked/root',
        asset_dir: '/mocked/asset',
        gem_layer_asset_dir: '/mocked/gem-layer-asset-dir'
      )
      application.config = config
    end

    it 'creates bundle hashes and shared code' do
      # Adding a mock resource that responds to #bundle
      mock_resource = double('Resource')
      allow(mock_resource).to receive(:bundle)
      application.add_resource(mock_resource)

      # Call the method under test
      application.bundle

      # Verifying that create_bundle_hashes and create_shared_code methods are called
      expect(Digest::SHA256).to have_received(:file).at_least(:once)
      expect(FileUtils).to have_received(:mkdir_p).at_least(:once)
      expect(FileUtils).to have_received(:cp_r).at_least(:once)

      # Verifying that the resource's #bundle method is called
      expect(mock_resource).to have_received(:bundle).once
    end
  end

  describe '#template' do
    let(:name) { 'test_app' }
    let(:code_dir) { 'code_dir' }
    let(:stacks) { ['test_stack'] }
    let(:application) { described_class.new(name: name, code_dir: code_dir, stacks: stacks, skip_gem_layer: true) }

    before do
      # Stubbing the configuration
      config = double('Config', root_dir: '/mocked/root', asset_dir: '/mocked/asset')
      application.config = config
    end

    it 'returns the correct template structure' do
      # Stubbing a resource with a mock synthesize method
      mock_resource = double('Resource')
      allow(mock_resource).to receive(:synthesize).and_return('mocked_resource' => { 'type' => 'mock' })
      application.add_resource(mock_resource)

      # Expected template output
      expected_template = {
        'name' => 'test_app',
        'runtime' => 'yaml',
        'resources' => {
          'mocked_resource' => { 'type' => 'mock' }
        }
      }

      # Assert that the template method returns the expected structure
      expect(YAML.safe_load(application.template)).to eq(expected_template)
    end
  end
end
