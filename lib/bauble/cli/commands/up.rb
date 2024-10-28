# frozen_string_literal: true

require 'thor'
require_relative '../pulumi'
require_relative '../logger'

module Bauble
  module Cli
    module Commands
      # Up command
      module Up
        class << self
          def included(thor)
            thor.class_eval do
              desc 'up', 'Deploy the application'
              method_option :stack, type: :string, desc: 'The stack to stand up', aliases: '-s'

              def up
                Logger.logo

                setup_app

                # check for any stacks
                raise 'No stacks found' if @app.stacks.empty?

                # check for multiple stacks
                if @app.stacks.length > 1 && options[:stack].nil?
                  Logger.error 'Must provide a stack when multiple are defined'
                  exit(1)
                end

                # set up stack
                stack_name = options[:stack] || @app.stacks.first.name
                @app.change_current_stack(stack_name)

                # bundle assets
                Logger.block_log 'Bundling assets...'
                Logger.nl
                @app.bundle

                # write template file
                pulumi.create_pulumi_yml(@app.template)

                # initialize pulumi
                pulumi.init!

                # create or select stack
                pulumi.create_or_select_stack(stack_name)

                # deploy the rest
                Logger.block_log 'Deploying application resources...'
                pulumi.up

                # log completion
                Logger.log "Up complete\n"
              end
            end
          end
        end
      end
    end
  end
end
