# frozen_string_literal: true

require 'zip'
require_relative 'base_resource'
require_relative '../cli/code_bundler'

# Ruby function
module Bauble
  module Resources
    # a ruby lambda function
    class GemLayer < BaseResource
      def bundle
        Bauble::Cli::CodeBundler.docker_bundle_gems(bundle_hash: @app.bundle_hash)
      end

      def synthesize
        {
          'gemLayer' => {
            'type' => 'aws:lambda:LayerVersion',
            'name' => 'gem_layer',
            'properties' => {
              'code' => {
                'fn::fileArchive' => "#{@app.config.asset_dir}/#{@app.bundle_hash}/gem-layer"
              },
              'layerName' => "#{@app.config.app_name}-gem-layer",
              'compatibleRuntimes' => %w[ruby3.2]
            }
          }
        }
      end
    end
  end
end
