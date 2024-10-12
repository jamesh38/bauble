# frozen_string_literal: true

module Bauble
  module Cli
    # app config
    class Config
      attr_accessor(
        :app_name,
        :bauble_home,
        :pulumi_home,
        :app_stack_name,
        :debug,
        :asset_dir,
        :root_dir,
        :skip_gem_layer,
        :gem_layer_asset_dir,
        :shared_code_asset_dir
      )

      def initialize
        @root_dir = Dir.pwd
        @bauble_home = "#{@root_dir}/.bauble"
        @asset_dir = "#{@bauble_home}/assets"
        @pulumi_home = "#{@bauble_home}/.pulumi"
        @gem_layer_asset_dir = "#{@asset_dir}/gem_layer"
        @shared_code_asset_dir = "#{@asset_dir}/shared_app_code"
        @app_stack_name = 'bauble'
        @debug = ENV['BAUBLE_DEBUG'] || false
        @skip_gem_layer = false
        set_pulumi_env_vars
      end

      def self.configure
        config = new
        yield(config) if block_given?
        config
      end

      private

      def set_pulumi_env_vars
        ENV['PULUMI_HOME'] = @pulumi_home
        ENV['PULUMI_CONFIG_PASSPHRASE'] = ''
        ENV['PULUMI_SKIP_UPDATE_CHECK'] = 'true'
      end
    end
  end
end
