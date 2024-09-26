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

              def preview
                @app.change_current_stack('dev')
                pulumi.create_pulumi_yml(@app.template)
                pulumi.init!
                pulumi.create_or_select_stack('dev')
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
