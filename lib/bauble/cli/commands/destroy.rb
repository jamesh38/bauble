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
                write_template(@app.template)
                Bauble::Cli::Pulumi.destroy
                Logger.log('Destroy complete')
              end
            end
          end
        end
      end
    end
  end
end
