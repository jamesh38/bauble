# frozen_string_literal: true

require 'thor'
require_relative 'commands/preview'
require 'json'

# CLI tool
module Bauble
  module Cli
    # Bauble CLI
    class BaubleCli < Thor
      attr_accessor :app

      include Commands::Preview

      def initialize(*args)
        super
        require_entrypoint
        @app = ObjectSpace.each_object(Bauble::Application).first
        raise 'No App instance found' unless @app
      end

      private

      def require_entrypoint
        file = File.read('bauble.json')
        config = JSON.parse(file)
        require "#{Dir.pwd}/#{config['entrypoint']}"
      end
    end
  end
end
