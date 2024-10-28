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
require_relative 'logger'

module Bauble
  module Cli
    # Bauble CLI
    class BaubleCli < Thor
      include Commands::Preview
      include Commands::Up
      include Commands::Destroy
      include Commands::New

      attr_accessor :app, :config

      def self.exit_on_failure?
        true
      end

      no_commands do
        def setup_app
          require_entrypoint
          @app = ObjectSpace.each_object(Bauble::Application).first

          unless @app
            Logger.error 'No Bauble::Application object found'
            exit 1
          end

          build_config
        end
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
        unless File.exist?('bauble.json')
          Logger.error 'No bauble.json file found'
          exit 1
        end
        @bauble_json ||= JSON.parse(File.read('bauble.json'))
      end

      def require_entrypoint
        unless bauble_json['entrypoint']
          Logger.error 'No entrypoint found in bauble.json'
          exit 1
        end
        Kernel.require "#{Dir.pwd}/#{bauble_json['entrypoint']}"
      end
    end
  end
end
