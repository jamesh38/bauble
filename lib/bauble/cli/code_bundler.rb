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
        def docker_bundle_gems(gem_path:)
          IO.popen("#{docker_build_gems_command(gem_path)} 2>&1") do |io|
            io.each do |line|
              Logger.docker(line)
            end
          end

          return if last_process_success?

          `rm -rf .bundle`
          Logger.error('Bundle step failed')
          exit
        end

        private

        def last_process_success?
          $CHILD_STATUS.success?
        end

        def docker_build_gems_command(gem_path)
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
                 .with_command(bundle_command(gem_path))
                 .build
        end

        def bundle_command(gem_path)
          command = BundleCommandBuilder
                    .new
                    .with_bundle_without(%w[test development])
                    .with_bundle_path(gem_path)

          command.with_bauble_gem_override if ENV['BAUBLE_DEV_GEM_PATH']

          command.with_bundle_install
                 .with_dot_bundle_cleanup
                 .build
        end
      end
    end
  end
end
