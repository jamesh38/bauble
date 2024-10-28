# frozen_string_literal: true

require 'thor'
require_relative '../pulumi'
require_relative '../logger'

module Bauble
  module Cli
    module Commands
      # Preview command
      module Preview
        class << self
          def included(thor)
            thor.class_eval do
              desc 'preview', 'Preview the application'
              method_option :stack, type: :string, desc: 'The stack to preview', aliases: '-s'

              def preview
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
                Logger.block_log('Running Pulumi preview...')
                pulumi.create_or_select_stack(stack_name)

                # run preview
                pulumi.preview
                Logger.log "Preview complete\n"
              end
            end
          end
        end
      end
    end
  end
end
