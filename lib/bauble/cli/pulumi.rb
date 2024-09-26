# frozen_string_literal: true

require_relative 'logger'
require 'English'

STACK_NAME = 'bauble-app'
BAUBLE_PULUMI_HOME = "#{Dir.pwd}/.bauble/.pulumi".freeze

ENV['PULUMI_HOME'] = BAUBLE_PULUMI_HOME
ENV['PULUMI_CONFIG_PASSPHRASE'] = ''
ENV['PULUMI_NON_INTERACTIVE'] = 'true'

# pulumi wrapper
module Bauble
  module Cli
    # Pulumi class
    module Pulumi
      PULUMI_HOME = BAUBLE_PULUMI_HOME

      class << self
        def preview
          init_pulumi unless pulumi_initialized?
          Logger.log "Running pulumi preview...\n"
          output_command('preview')
        end

        def up
          init_pulumi unless pulumi_initialized?
          Logger.log "Running pulumi up...\n"
          output_command('up --yes')
        end

        def destroy
          init_pulumi unless pulumi_initialized?
          Logger.log "Running pulumi destroy...\n"
          output_command('destroy --yes')
        end

        private

        def output_command(command)
          IO.popen("#{build_command(command)} 2>&1") do |io|
            io.each do |line|
              puts "[ Pulumi ] #{line}"
            end
          end
        end

        def run_command(command)
          `#{build_command(command)} 2>/dev/null`
        end

        def build_command(command)
          "pulumi #{command} #{global_flags.join(' ')}"
        end

        def global_flags
          [
            '--non-interactive',
            "--cwd #{PULUMI_HOME}"
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
            run_command("stack init --stack #{STACK_NAME}}")
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
          run_command('stack ls').include?(STACK_NAME)
        end

        def stack_selected?
          run_command('stack ls').lines.any? { |line| line.include?('*') }
        end

        def select_stack
          run_command("stack select --stack #{STACK_NAME}")
        end

        def pulumi_initialized?
          pulumi_logged_in? && stack_initialized?
        end
      end
    end
  end
end
