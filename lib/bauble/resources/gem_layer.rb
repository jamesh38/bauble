# frozen_string_literal: true

require_relative 'resource'
require_relative '../cli/code_bundler'

# Ruby function
module Bauble
  module Resources
    # a ruby lambda function
    class GemLayer < Resource
      def bundle
        FileUtils.mkdir_p("#{@app.config.gem_layer_asset_dir}/#{@app.gem_layer_hash}")

        Bauble::Cli::CodeBundler.docker_bundle_gems(
          gem_path: ".bauble/assets/gem_layer/#{@app.gem_layer_hash}"
        )
      end

      def synthesize
        {
          'gemLayer' => {
            'type' => 'aws:lambda:LayerVersion',
            'name' => resource_name('gem_layer'),
            'properties' => {
              'code' => {
                'fn::fileArchive' => "#{@app.config.gem_layer_asset_dir}/#{@app.gem_layer_hash}"
              },
              'layerName' => resource_name('gem_layer'),
              'compatibleRuntimes' => %w[ruby3.2]
            }
          }
        }
      end
    end
  end
end
