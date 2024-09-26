# frozen_string_literal: true

require_relative 'resources/s3_bucket'
require_relative 'resources/iam_role'
require 'yaml'

module Bauble
  # A Bauble application
  class Application
    attr_accessor :resources, :stacks, :current_stack

    def initialize
      @resources = []
      @stacks = []
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

    def change_current_stack(stack_name)
      @current_stack = @stacks.find { |stack| stack.name == stack_name }
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
        'name' => @current_stack.name,
        'runtime' => 'yaml',
        'resources' => {}
      }
    end
  end
end
