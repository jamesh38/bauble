# frozen_string_literal: true

require_relative 'config'
require 'thor'
require 'json'
require_relative 'commands/preview'
require_relative 'commands/up'
require_relative 'commands/destroy'
require_relative 'commands/new'
require_relative 'pulumi'
require_relative '../application'

module Bauble
  module Cli
    # Bauble CLI
    class BaubleCli < Thor
      include Commands::Preview
      include Commands::Up
      include Commands::Destroy
      include Commands::New

      attr_accessor :app, :config

      def initialize(*args)
        super
        require_entrypoint
        @app = ObjectSpace.each_object(Bauble::Application).first
        raise 'No App instance found' unless @app

        build_config
      end

      def self.exit_on_failure?
        true
      end

      private

      def pulumi
        @pulumi ||= Bauble::Cli::Pulumi.new(config: config)
      end

      def build_config
        @config = Config.configure do |c|
          c.app_name = @app.name
          c.skip_gem_layer = @app.skip_gem_layer
          c.s3_backend = @app.s3_backend
        end
        @app.config = @config
      end

      def write_stack_template(stack)
        create_directory
        # TODO: this can probably be put into something smarter, maube a file writing class?
        File.write("#{config.pulumi_home}/Pulumi.#{stack.name}.yaml", stack.template)
      end

      def create_directory
        FileUtils.mkdir_p(config.pulumi_home)
      end

      def bauble_json
        @bauble_json ||= JSON.parse(File.read('bauble.json'))
      end

      def require_entrypoint
        Kernel.require "#{Dir.pwd}/#{bauble_json['entrypoint']}"
      end
    end
  end
end
