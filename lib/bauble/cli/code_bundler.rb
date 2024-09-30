# frozen_string_literal: true

require 'logger'

module Bauble
  module Cli
    # bundle code
    class CodeBundler
      class << self
        def docker_bundle_gems(bundle_hash:)
          IO.popen("#{docker_command(bundle_hash)} 2>&1") do |io|
            io.each do |line|
              Logger.docker(line)
            end
          end
          `rm -rf .bundle`
        end

        private

        # TODO: Remove the need for this to install things from the sub dir
        def docker_command(bundle_hash)
          'docker run ' \
          '--rm ' \
          '-v $(pwd)/../:/var/task ' \
          '-w /var/task/demo_app ' \
          '--entrypoint /bin/sh ' \
          '--platform linux/amd64 ' \
          'public.ecr.aws/sam/build-ruby3.2 ' \
          "-c \"#{bundle_command(bundle_hash)}\""
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
