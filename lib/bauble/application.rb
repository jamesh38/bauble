# frozen_string_literal: true

require_relative 'resources/s3_bucket'
require_relative 'resources/iam_role'
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
      :bundle_hash
    )

    def initialize(name:, stacks: [])
      @resources = []
      add_gem_layer
      @stacks = []
      @name = name
      @code_dir = "#{Dir.pwd}/app"
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
      @resources << Bauble::Resources::GemLayer.new(self)
    end

    def change_current_stack(stack_name)
      @current_stack = @stacks.find { |stack| stack.name == stack_name }
    end

    def bundle
      # TODO: this potentially need to be a hash of more resources I'm not sure yet'
      @bundle_hash = generate_unique_string("#{Dir.pwd}/app")
      @resources.each(&:bundle)
    end

    private

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
