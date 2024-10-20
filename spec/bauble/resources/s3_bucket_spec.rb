# frozen_string_literal: true

describe Bauble::Resources::S3Bucket do
  let(:app) { instance_double(Bauble::Application) }
  let(:bucket_name) { 'test-bucket' }
  let(:force_destroy) { true }

  before do
    allow(app).to receive(:add_resource)
    allow(app).to receive(:current_stack).and_return(double(name: 'my-stack'))
    allow(app).to receive(:name).and_return('my-app')
  end

  describe '#initialize' do
    it 'sets the name and force_destroy attributes correctly' do
      bucket = described_class.new(app, name: bucket_name, force_destroy: force_destroy)
      expect(bucket.name).to eq(bucket_name)
      expect(bucket.force_destroy).to eq(force_destroy)
    end

    it 'uses default values when no arguments are provided' do
      bucket = described_class.new(app)
      expect(bucket.name).to eq('bauble-bucket')
      expect(bucket.force_destroy).to eq(false)
    end
  end

  describe '#synthesize' do
    it 'returns the correct resource structure' do
      bucket = described_class.new(app, name: bucket_name, force_destroy: force_destroy)
      expected_structure = {
        bucket_name => {
          'type' => 'aws:s3:Bucket',
          'properties' => {
            'bucket' => bucket.resource_name(bucket_name),
            'forceDestroy' => force_destroy
          }
        }
      }

      expect(bucket.synthesize).to eq(expected_structure)
    end
  end

  describe '#bundle' do
    it 'returns true' do
      bucket = described_class.new(app)
      expect(bucket.bundle).to be true
    end
  end
end
