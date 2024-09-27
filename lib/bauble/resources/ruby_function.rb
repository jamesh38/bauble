# frozen_string_literal: true

require 'zip'
require_relative 'base_resource'

# Ruby function
module Bauble
  module Resources
    # a ruby lambda function
    class RubyFunction < BaseResource
      attr_accessor :handler, :name, :role, :code_dir, :function_url

      def initialize(app, name:, handler:, code_dir:, role: nil, function_url: false)
        super(app)
        @name = name
        @handler = handler
        @code_dir = code_dir
        @role = role
        @function_url = function_url
      end

      def bundle
        # generate the asset directory path
        assets_dir = File.join(@app.config.asset_dir, @app.bundle_hash)

        # create the asset directory if it doesn't exist
        FileUtils.mkdir_p(assets_dir)

        # create the zipfile path
        zipfile_name = File.join(assets_dir, "#{name}.zip")

        # remove the zipfile if it already exists
        FileUtils.rm_f(zipfile_name)

        # create the zipfile
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          # add the code directory to the zipfile
          Dir.glob(File.join(@code_dir, '**', '*')).each do |file|
            zipfile_path = File.join(File.basename(@code_dir), file.sub("#{code_dir}/", ''))
            zipfile.add(zipfile_path, file)
          end

          # add the Gemfile and Gemfile.lock to the zipfile
          gemfile_path = File.join(Dir.pwd, 'Gemfile')
          gemfile_lock_path = File.join(Dir.pwd, 'Gemfile.lock')
          zipfile.add('Gemfile', gemfile_path) if File.exist?(gemfile_path)
          zipfile.add('Gemfile.lock', gemfile_lock_path) if File.exist?(gemfile_lock_path)
        end
      end

      def synthesize
        template = base_template
        template.merge!(function_url_template_addon) if @function_url
        template
      end

      def base_template
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

      def function_url_template_addon
        {
          'function_url' => {
            'type' => 'aws:lambda:FunctionUrl',
            'name' => "#{@name}Url",
            'properties' => {
              'functionName' => "${#{@name}}",
              'authorizationType' => 'NONE'
            }
          }
        }
      end
    end
  end
end
