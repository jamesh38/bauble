# frozen_string_literal: true

require 'thor'
require_relative '../pulumi'
require_relative '../logger'

module Bauble
  module Cli
    module Commands
      # Up command
      module Destroy
        class << self
          def included(thor)
            thor.class_eval do
              desc 'destroy', 'Destroy the application'
              method_option :stack, type: :string, desc: 'The stack to destroy', aliases: '-s'

              def destroy
                Logger.logo
                Logger.nl

                # check for any stacks
                raise 'No stacks found' if @app.stacks.empty?

                # check for multiple stacks
                if @app.stacks.length > 1 && options[:stack].nil?
                  Log.error 'Must provide a stack when multiple are defined'
                  exit(1)
                end

                unless yes?('Are you sure you want to destroy the application? [y/N]')
                  Logger.log('Destroy aborted')
                  exit(0)
                end

                Logger.block_log('Destroying application...')

                # set up stack
                stack_name = options[:stack] || @app.stacks.first.name
                @app.change_current_stack(stack_name)

                # initialize pulumi
                pulumi.init!

                # create or select stack
                pulumi.create_or_select_stack(stack_name)

                # destroy the stack
                pulumi.destroy
                Logger.log "Destroy complete\n"
              end
            end
          end
        end
      end
    end
  end
end
