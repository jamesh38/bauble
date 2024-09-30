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

        def docker_command(bundle_hash)
          'docker run --rm ' \
          '-v $(pwd)/../:/var/task ' \
          '-w /var/task ' \
          '--entrypoint /bin/sh ' \
          '--platform linux/amd64 ' \
          'ruby:3.2 ' \
          "-c \"#{bundle_command(bundle_hash)}\""
        end

        def bundle_command(bundle_hash)
          "bundle config set without 'development' && " \
          "bundle config set path \"demo_app/.bauble/assets/#{bundle_hash}/gem-layer\" && " \
          'bundle install && ' \
          'rm -rf .bundle'
        end
      end
    end
  end
end
