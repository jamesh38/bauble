# frozen_string_literal: true

require 'thor'

module Bauble
  module Cli
    module Commands
      # Preview command
      module Preview
        def self.included(thor)
          thor.class_eval do
            desc 'preview', 'Preview the application'

            def preview
              @app.synthesize_template
              Pulumi.instance.preview
            end
          end
        end
      end
    end
  end
end
