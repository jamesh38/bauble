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
      :shared_code_hash,
      :gem_layer_hash,
      :skip_gem_layer
    )

    def initialize(name:, code_dir:, stacks: [], skip_gem_layer: false)
      # passed arguments
      @name = name
      @shared_code_dir = code_dir
      @stacks = []
      @skip_gem_layer = skip_gem_layer

      # init others
      @resources = []

      # add gem layer by defalt
      add_gem_layer unless skip_gem_layer

      # create a default stack if none passed
      stacks = ['dev'] if stacks.empty?
      stacks.each do |stack|
        Stack.new(self, stack)
      end
      @current_stack = @stacks[0]
    end

    def template
      @template ||= synthesize_template
    end

    def change_current_stack(stack_name)
      stack = @stacks.find { |st| st.name == stack_name }
      unless stack
        Bauble::Cli::Logger.error "Unknown stack #{stack_name}"
        exit(1)
      end

      @current_stack = stack
    end

    def bundle
      create_bundle_hashes
      create_shared_code
      @resources.each(&:bundle)
    end

    def add_resource(resource)
      @resources << resource
    end

    def add_stack(stack)
      @stacks << stack
    end

    private

    def create_bundle_hashes
      @bundle_hash = hash_of_dir("#{Dir.pwd}/#{code_dir}")
      @shared_code_hash = hash_of_dir("#{@config.root_dir}/#{@shared_code_dir}") if @shared_code_dir
      @gem_layer_hash = hash_of_file("#{@config.root_dir}/Gemfile") unless @skip_gem_layer
    end

    def add_gem_layer
      Bauble::Resources::GemLayer.new(self)
    end

    def create_shared_code
      return unless @shared_code_dir

      destination_dir = File.join(
        config.asset_dir,
        'shared_app_code',
        @shared_code_hash,
        @shared_code_dir
      )
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

    def hash_of_dir(directory)
      files = Dir.glob("#{directory}/**/*").select { |file| File.file?(file) }
      content_hash = files.map { |file| Digest::SHA256.file(file).hexdigest }.join
      Digest::SHA256.hexdigest(content_hash)
    end

    def hash_of_file(filename)
      Digest::SHA256.file(filename).hexdigest
    end
  end
end
