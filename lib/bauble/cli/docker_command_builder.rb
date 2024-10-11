# frozen_string_literal: true

module Bauble
  module Cli
    # Builds a docker command
    class DockerCommandBuilder
      def initialize
        @command = 'docker run '
      end

      def with_rm
        @command += '--rm '
        self
      end

      def with_volume(volume)
        @command += "-v #{volume} "
        self
      end

      def with_workdir(workdir)
        @command += "-w #{workdir} "
        self
      end

      def with_entrypoint(entrypoint)
        @command += "--entrypoint #{entrypoint} "
        self
      end

      def with_platform(platform)
        @command += "--platform #{platform} "
        self
      end

      def with_image(image)
        @command += "#{image} "
        self
      end

      def with_command(cmd)
        @command += "-c \"#{cmd}\""
        self
      end

      def with_env(key, value)
        @command += "-e #{key}=#{value} "
        self
      end

      def build
        @command
      end
    end
  end
end
