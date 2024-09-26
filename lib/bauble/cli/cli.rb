# frozen_string_literal: true

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
      attr_accessor :app

      include Commands::Preview
      include Commands::Up
      include Commands::Destroy

      def initialize(*args)
        super
        require_entrypoint
        @app = ObjectSpace.each_object(Bauble::Application).first
        raise 'No App instance found' unless @app
      end

      private

      def write_template(template_string)
        create_directory
        File.open("#{Pulumi::PULUMI_HOME}/Pulumi.yaml", 'w') { |file| file.write(template_string) }
      end

      def create_directory
        FileUtils.mkdir_p(Pulumi::PULUMI_HOME)
      end

      def require_entrypoint
        file = File.read('bauble.json')
        config = JSON.parse(file)
        require "#{Dir.pwd}/#{config['entrypoint']}"
      end
    end
  end
end
