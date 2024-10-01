# frozen_string_literal: true

require 'logger'
require_relative 'docker_command_builder'

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
          `rm -rf .bundle`
        end

        private

        # TODO: Remove the need for this to install things from the sub dir
        def docker_build_gems_command(bundle_hash)
          DockerCommandBuilder
            .new
            .with_rm
            .with_volume('$(pwd)/../:/var/task')
            .with_workdir('/var/task/demo_app')
            .with_entrypoint('/bin/sh')
            .with_platform('linux/amd64')
            .with_image('public.ecr.aws/sam/build-ruby3.2')
            .with_command(bundle_command(bundle_hash))
            .build
        end

        def bundle_command(bundle_hash)
          'bundle config set without test development && ' \
          "bundle config set path \".bauble/assets/#{bundle_hash}/gem-layer\" && " \
          'bundle install && ' \
          'rm -rf .bundle'
        end
      end
    end
  end
end
