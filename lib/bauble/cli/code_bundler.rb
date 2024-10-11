# frozen_string_literal: true

require 'logger'
require 'English'
require_relative 'docker_command_builder'
require_relative 'bundle_command_builder'

module Bauble
  module Cli
    # bundle code
    class CodeBundler
      class << self
        def docker_bundle_gems(bundle_hash:)
          IO.popen("#{docker_build_gems_command(bundle_hash)} 2>&1") do |io|
            io.each do |line|
              Logger.docker(line)
            end
          end

          return if $CHILD_STATUS.success?

          `rm -rf .bundle`
          Logger.error('Bundle step failed')
          exit
        end

        private

        # TODO: Remove the need for this to install things from the sub dir
        def docker_build_gems_command(bundle_hash)
          command = DockerCommandBuilder
                    .new
                    .with_rm
                    .with_volume('$(pwd):/var/task')
                    .with_workdir('/var/task')
                    .with_entrypoint('/bin/sh')
                    .with_platform('linux/amd64')

          if ENV['BAUBLE_DEV_GEM_PATH']
            command = command.with_volume("#{ENV['BAUBLE_DEV_GEM_PATH']}:/var/task/bauble_core")
          end

          command.with_image('public.ecr.aws/sam/build-ruby3.2')
                 .with_command(bundle_command(bundle_hash))
                 .build
        end

        def bundle_command(bundle_hash)
          command = BundleCommandBuilder
                    .new
                    .with_bundle_without(%w[test development])
                    .with_bundle_path(bundle_hash)

          command.with_bauble_gem_override if ENV['BAUBLE_DEV_GEM_PATH']

          command.with_bundle_install
                 .with_dot_bundle_cleanup
                 .build
        end
      end
    end
  end
end
