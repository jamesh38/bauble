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
                write_template(@app.template)
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
