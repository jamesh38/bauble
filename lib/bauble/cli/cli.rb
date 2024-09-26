# frozen_string_literal: true

require_relative 'config'
require 'thor'
require 'json'
require_relative 'commands/preview'
require_relative 'commands/up'
require_relative 'commands/destroy'
require_relative 'pulumi'

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
        build_config
        require_entrypoint
        @app = ObjectSpace.each_object(Bauble::Application).first
        raise 'No App instance found' unless @app
      end

      private

      def pulumi
        @pulumi ||= Bauble::Cli::Pulumi.new(config: config)
      end

      def build_config
        @config = Config.configure do |c|
          c.app_name = bauble_json['name']
        end
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
