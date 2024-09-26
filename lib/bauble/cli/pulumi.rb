# frozen_string_literal: true

require_relative 'logger'
require 'English'

ENV['PULUMI_HOME'] = "#{Dir.pwd}/.bauble"
ENV['PULUMI_CONFIG_PASSPHRASE'] = ''
ENV['PULUMI_NON_INTERACTIVE'] = 'true'

# pulumi wrapper
module Bauble
  module Cli
    # Pulumi class
    module Pulumi
      class << self
        def preview
          init_pulumi unless pulumi_initialized?
          Logger.log "Running pulumi preview...\n"
          output_command('preview')
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
            '--cwd .bauble'
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
            run_command('stack init --stack bauble-app')
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
          run_command('stack ls').include?('bauble-app')
        end

        def stack_selected?
          run_command('stack ls').lines.any? { |line| line.include?('*') }
        end

        def select_stack
          run_command('stack select --stack bauble-app')
        end

        def pulumi_initialized?
          pulumi_logged_in? && stack_initialized?
        end
      end
    end
  end
end
