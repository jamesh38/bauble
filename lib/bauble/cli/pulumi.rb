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

      def create_pulumi_yml(template)
        Logger.debug 'Creating Pulumi.yaml...'
        FileUtils.mkdir_p(@config.pulumi_home)
        File.write("#{@config.pulumi_home}/Pulumi.yaml", template, mode: 'w')
      end

      def init!
        init_pulumi unless pulumi_initialized?
      end

      def preview
        Logger.debug "Running pulumi preview...\n"
        output_command('preview')
      end

      def up(target = nil)
        Logger.debug "Running pulumi up...\n"
        output_command("up --yes#{target ? " --target #{target}" : ''}")
      end

      def destroy
        Logger.debug "Running pulumi destroy...\n"
        output_command('destroy --yes')
      end

      def create_or_select_stack(stack_name)
        if stack_initialized?(stack_name)
          Logger.debug "Selecting stack #{stack_name}"
          select_stack(stack_name)
        else
          Logger.debug "Initializing stack #{stack_name}"
          init_stack(stack_name)
        end
      end

      private

      def pulumi_initialized?
        return false unless pulumi_yml_exists?

        pulumi_logged_in?
      end

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
      end

      def pulumi_yml_exists?
        Logger.debug "Checking for Pulumi.yaml... #{File.exist?("#{@config.pulumi_home}/Pulumi.yaml")}"
        File.exist?("#{@config.pulumi_home}/Pulumi.yaml")
      end

      def login
        Logger.debug 'Logging into pulumi locally...'
        run_command('login --local')
      end

      def pulumi_logged_in?
        run_command('whoami')
        success = pulumi_command_success?
        Logger.debug "Checking pulumi login status... #{success}"
        success
      end

      def init_stack(stack_name)
        run_command("stack init --stack #{stack_name}")
      end

      def select_stack(stack_name)
        run_command("stack select --stack #{stack_name}")
      end

      def stack_initialized?(stack_name)
        Logger.debug "Checking if stack #{stack_name} is initialized..."
        run_command('stack ls').include?(stack_name)
      end

      def pulumi_command_success?
        $CHILD_STATUS.success?
      end
    end
  end
end
