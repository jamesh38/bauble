# frozen_string_literal: true

require_relative 'resources/s3_bucket'
require_relative 'resources/iam_role'
require 'yaml'

module Bauble
  # A Bauble application
  class Application
    attr_accessor :resources

    def initialize
      @resources = []
      @resources << Bauble::Resources::IamRole.new(self, role_name: 'lambda-role')
      @resources << Bauble::Resources::S3Bucket.new(self)
    end

    def add_resource(resource)
      @resources << resource
    end

    def template
      @template ||= synthesize_template
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
        'name' => 'bauble',
        'runtime' => 'yaml',
        'resources' => {}
      }
    end
  end
end
