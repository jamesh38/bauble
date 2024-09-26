# frozen_string_literal: true

require_relative 'logger'
require 'English'

# pulumi wrapper
module Bauble
  module Cli
    # Pulumi class
    class Pulumi
      attr_accessor :config

      def initialize(config:)
        @config = config
      end

      def preview
        init_pulumi unless pulumi_initialized?
        Logger.logo
        Logger.log "Running pulumi preview...\n"
        output_command('preview')
      end

      def up
        init_pulumi unless pulumi_initialized?
        Logger.logo
        Logger.log "Running pulumi up...\n"
        output_command('up --yes')
      end

      def destroy
        init_pulumi unless pulumi_initialized?
        Logger.logo
        Logger.log "Running pulumi destroy...\n"
        output_command('destroy --yes')
      end

      private

      def output_command(command)
        Logger.nl
        IO.popen("#{build_command(command)} 2>&1") do |io|
          io.each do |line|
            Logger.pulumi(line)
          end
        end
        Logger.nl
      end

      def run_command(command)
        `#{build_command(command)}#{silent_mode}`
      end

      def silent_mode
        @config.debug ? '' : ' 2>/dev/null'
      end

      def build_command(command)
        "pulumi #{command} #{global_flags.join(' ')}"
      end

      def global_flags
        [
          '--non-interactive',
          "--cwd #{@config.pulumi_home}"
        ]
      end

      def init_pulumi
        login
        init_stack
      end

      def init_stack
        if stack_initialized?
          select_stack unless stack_selected?
        else
          run_command("stack init --stack #{@config.app_stack_name}")
        end
      end

      def login
        return if pulumi_logged_in?

        Logger.log 'Logging into pulumi locally...'
        run_command('login --local')
      end

      def pulumi_logged_in?
        run_command('whoami')
        $CHILD_STATUS.success?
      end

      def stack_initialized?
        run_command('stack ls').include?(@config.app_stack_name)
      end

      def stack_selected?
        run_command('stack ls').lines.any? { |line| line.include?('*') }
      end

      def select_stack
        run_command("stack select --stack #{@config.app_stack_name}")
      end

      def pulumi_initialized?
        pulumi_logged_in? && stack_initialized?
      end
    end
  end
end
