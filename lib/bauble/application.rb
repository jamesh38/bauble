# frozen_string_literal: true

require_relative 'resources/s3_bucket'
require_relative 'resources/lambda_role'
require_relative 'stack'
require_relative 'cli/logger'
require 'yaml'
require 'digest'

module Bauble
  # A Bauble application
  class Application
    attr_accessor(
      :resources,
      :stacks,
      :current_stack,
      :name,
      :config,
      :code_dir,
      :bundle_hash,
      :shared_code_dir,
      :skip_gem_layer
    )

    def initialize(name:, stacks: [], code_dir: nil, skip_gem_layer: false)
      @resources = []
      @stacks = []
      @name = name
      @shared_code_dir = code_dir
      @skip_gem_layer = skip_gem_layer
      add_gem_layer unless skip_gem_layer
      stacks = ['dev'] if stacks.empty?
      stacks.each do |stack|
        Stack.new(self, stack)
      end
    end

    def add_resource(resource)
      @resources << resource
    end

    def add_stack(stack)
      @stacks << stack
    end

    def template
      @template ||= synthesize_template
    end

    def add_gem_layer
      Bauble::Resources::GemLayer.new(self)
    end

    def change_current_stack(stack_name)
      @current_stack = @stacks.find { |stack| stack.name == stack_name }
    end

    def bundle
      # TODO: this potentially need to be a hash of more resources I'm not sure yet'
      @bundle_hash = generate_unique_string("#{Dir.pwd}/app")
      create_shared_code
      @resources.each(&:bundle)
    end

    private

    def create_shared_code
      return unless @shared_code_dir

      destination_dir = File.join(config.asset_dir, @bundle_hash, 'shared_app_code', File.basename(@shared_code_dir))
      FileUtils.mkdir_p(destination_dir)
      FileUtils.cp_r(Dir.glob(File.join(@shared_code_dir, '*')), destination_dir)
    end

    def synthesize_template
      all_resources = @resources.map(&:synthesize).reduce({}, :merge)
      template = base_template
      template['resources'] = all_resources
      template.to_yaml
    end

    def base_template
      {
        'name' => @name,
        'runtime' => 'yaml',
        'resources' => {}
      }
    end

    def generate_unique_string(directory)
      files = Dir.glob("#{directory}/**/*").select { |file| File.file?(file) }
      content_hash = files.map { |file| Digest::SHA256.file(file).hexdigest }.join
      Digest::SHA256.hexdigest(content_hash)
    end
  end
end
