# frozen_string_literal: true

module Bauble
  module Cli
    # bundle command builder
    class BundleCommandBuilder
      def initialize
        @commands = []
      end

      def with_bundle_without(groups)
        @commands << "bundle config set without #{groups.join(' ')}"
        self
      end

      def with_bundle_path(bundle_hash)
        @commands << "bundle config set path \".bauble/assets/#{bundle_hash}/gem-layer\""
        self
      end

      def with_bauble_gem_override
        @commands << 'bundle config local.bauble_core /var/task/bauble_core'
        self
      end

      def with_bundle_install
        @commands << 'bundle install'
        self
      end

      def with_dot_bundle_cleanup
        @commands << 'rm -rf .bundle'
        self
      end

      def build
        @commands.join(' && ')
      end
    end
  end
end
