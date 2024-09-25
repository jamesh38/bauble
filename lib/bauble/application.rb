# frozen_string_literal: true

require_relative 'resources/s3_bucket'
require_relative 'resources/iam_role'
require_relative 'pulumi'
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

    def synthesize_template
      all_resources = @resources.map(&:synth).reduce({}, :merge)
      template = base_template
      template['resources'] = all_resources
      write_template(template.to_yaml)
    end

    private

    def base_template
      {
        'name' => 'bauble',
        'runtime' => 'yaml',
        'resources' => {}
      }
    end

    def write_template(template_string)
      create_directory
      File.open('.bauble/Pulumi.yaml', 'w') { |file| file.write(template_string) }
    end

    def create_directory
      Dir.mkdir('.bauble') unless File.directory?('.bauble')
    end
  end
end
