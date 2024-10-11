# frozen_string_literal: true

require_relative 'resource'
require_relative '../cli/docker_command_builder'
require_relative '../cli/logger'

module Bauble
  module Resources
    # Postgres layer
    class PostgresLayer < Resource
      def bundle
        IO.popen("docker build -t bauble_postgres_layer #{__dir__}/../cli/Dockerfile.postgres } 2>&1") do |io|
          io.each do |line|
            Bauble::Cli::Logger.docker(line)
          end
        end

        IO.popen("#{docker_command} 2>&1") do |io|
          io.each do |line|
            Bauble::Cli::Logger.docker(line)
          end
        end
      end

      def synthesize
        {}
      end

      private

      def docker_command
        Bauble::Cli::DockerCommandBuilder
          .new
          .with_rm
          .with_volume('pg-layer:/opt/pgsql')
          .with_platform('linux/amd64')
          .with_image('bauble_postgres_layer')
          .build
      end
    end
  end
end
