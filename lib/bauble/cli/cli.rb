# frozen_string_literal: true

require_relative 'config'
require 'thor'
require 'json'
require_relative 'commands/preview'
require_relative 'commands/up'
require_relative 'commands/destroy'
require_relative 'pulumi'
require_relative '../application'

module Bauble
  module Cli
    # Bauble CLI
    class BaubleCli < Thor
      include Commands::Preview
      include Commands::Up
      include Commands::Destroy

      attr_accessor :app, :config

      def initialize(*args)
        super
        require_entrypoint
        @app = ObjectSpace.each_object(Bauble::Application).first
        build_config
        raise 'No App instance found' unless @app
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
        end
        @app.config = @config
      end

      def write_stack_template(stack)
        create_directory
        File.open("#{config.pulumi_home}/Pulumi.#{stack.name}.yaml", 'w') { |file| file.write(stack.template) }
      end

      def create_directory
        FileUtils.mkdir_p(config.pulumi_home)
      end

      def bauble_json
        @bauble_json ||= JSON.parse(File.read('bauble.json'))
      end

      def require_entrypoint
        require "#{Dir.pwd}/#{bauble_json['entrypoint']}"
      end
    end
  end
end
