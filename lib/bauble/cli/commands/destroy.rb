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

                raise 'No stacks found' if @app.stacks.empty?
                raise 'Must provide a stack when multiple are defined' if @app.stacks.length > 1 && options[:stack].nil?

                stack_name = options[:stack] || @app.stacks.first.name
                @app.change_current_stack(stack_name)
                pulumi.create_pulumi_yml(@app.template)
                pulumi.init!
                pulumi.create_or_select_stack(stack_name)
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
