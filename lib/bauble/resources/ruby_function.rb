# frozen_string_literal: true

require 'zip'
require_relative 'base_resource'

# Ruby function
module Bauble
  module Resources
    # a ruby lambda function
    class RubyFunction < BaseResource
      attr_accessor :handler, :name, :role

      def initialize(app, name:, handler:, role: nil)
        super(app)
        @name = name
        @handler = handler
        @role = role
      end

      def bundle
        assets_dir = File.join(Dir.pwd, '.bauble', 'assets', @app.bundle_hash)
        FileUtils.mkdir_p(assets_dir)

        zipfile_name = File.join(assets_dir, "#{name}.zip")
        FileUtils.rm_f(zipfile_name)

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          Dir.glob('app/**/*').each do |file|
            zipfile.add(file.sub('app/', ''), file)
          end
        end
      end

      def synthesize
        {
          @name => {
            'type' => 'aws:lambda:Function',
            'name' => @name,
            'properties' => {
              'handler' => @handler,
              'runtime' => 'ruby3.2',
              'code' => {
                'fn::fileArchive' => "#{@app.config.asset_dir}/#{@app.bundle_hash}/#{@name}.zip"
              },
              'role' => "${#{@role.role_name}.arn}"
            }
          }
        }
      end
    end
  end
end
