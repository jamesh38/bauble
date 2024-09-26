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

              def destroy
                @app.change_current_stack('dev')
                pulumi.create_pulumi_yml(@app.template)
                pulumi.init!
                pulumi.create_or_select_stack('dev')
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
