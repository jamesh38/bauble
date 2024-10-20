# frozen_string_literal: true

describe Bauble::Resources::GemLayer do
  let(:app) do
    instance_double(
      Bauble::Application,
      name: 'test_app',
      current_stack: double(name: 'test_stack'),
      config: double(gem_layer_asset_dir: '.bauble/assets/gem_layer'),
      gem_layer_hash: 'mocked_hash'
    )
  end

  before do
    allow(app).to receive(:add_resource)
    allow(FileUtils).to receive(:mkdir_p)
    allow(Bauble::Cli::CodeBundler).to receive(:docker_bundle_gems)
  end

  describe '#initialize' do
    it 'adds itself to the application resources' do
      gem_layer = described_class.new(app)
      expect(app).to have_received(:add_resource).with(gem_layer)
    end
  end

  describe '#bundle' do
    it 'creates the necessary directories and calls docker_bundle_gems' do
      gem_layer = described_class.new(app)
      gem_layer.bundle

      expected_path = "#{app.config.gem_layer_asset_dir}/#{app.gem_layer_hash}"
      expect(FileUtils).to have_received(:mkdir_p).with(expected_path)
      expect(Bauble::Cli::CodeBundler).to have_received(:docker_bundle_gems).with(
        gem_path: ".bauble/assets/gem_layer/#{app.gem_layer_hash}"
      )
    end
  end

  describe '#synthesize' do
    it 'returns the correct layer structure' do
      gem_layer = described_class.new(app)
      expected_structure = {
        'gemLayer' => {
          'type' => 'aws:lambda:LayerVersion',
          'name' => gem_layer.resource_name('gem_layer'),
          'properties' => {
            'code' => {
              'fn::fileArchive' => "#{app.config.gem_layer_asset_dir}/#{app.gem_layer_hash}"
            },
            'layerName' => gem_layer.resource_name('gem_layer'),
            'compatibleRuntimes' => %w[ruby3.2]
          }
        }
      }

      expect(gem_layer.synthesize).to eq(expected_structure)
    end
  end
end
