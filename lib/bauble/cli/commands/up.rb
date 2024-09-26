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

              def up
                @app.change_current_stack('dev')
                pulumi.create_pulumi_yml(@app.template)
                pulumi.init!
                pulumi.create_or_select_stack('dev')
                pulumi.up
                Logger.log "Up complete\n"
              end
            end
          end
        end
      end
    end
  end
end
