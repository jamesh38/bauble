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
                write_template(@app.template)
                Bauble::Cli::Pulumi.preview
                Logger.log('Preview complete')
              end
            end
          end
        end
      end
    end
  end
end
