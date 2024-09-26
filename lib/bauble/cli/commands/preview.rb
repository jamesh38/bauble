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

              private

              def write_template(template_string)
                create_directory
                File.open('.bauble/Pulumi.yaml', 'w') { |file| file.write(template_string) }
              end

              def create_directory
                Dir.mkdir('.bauble') unless File.directory?('.bauble')
              end
            end
          end
        end
      end
    end
  end
end
