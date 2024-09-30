# frozen_string_literal: true

require 'zip'
require_relative 'resource'

# Ruby function
module Bauble
  module Resources
    # a ruby lambda function
    class RubyFunction < Resource
      attr_accessor :handler, :name, :role, :code_dir, :function_url, :env_vars

      def initialize(app, **kwargs)
        super(app)
        @name = kwargs[:name]
        @handler = kwargs[:handler]
        @code_dir = kwargs[:code_dir]
        @role = kwargs[:role]
        @function_url = kwargs.fetch(:function_url, false)
        @env_vars = kwargs.fetch(:env_vars, {})
      end

      def bundle
        # generate the asset directory path
        assets_dir = File.join(@app.config.asset_dir, @app.bundle_hash)
        FileUtils.mkdir_p(assets_dir)

        # create the zipfile path
        zipfile_name = File.join(assets_dir, "#{name}.zip")
        FileUtils.rm_f(zipfile_name)

        # create the zipfile
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          # add the code directory to the zipfile
          Dir.glob(File.join(@code_dir, '**', '*')).each do |file|
            zipfile_path = File.join(File.basename(@code_dir), file.sub("#{code_dir}/", ''))
            zipfile.add(zipfile_path, file)
          end

          %w[Gemfile Gemfile.lock].each do |gemfile|
            gemfile_path = File.join(@app.config.root_dir, gemfile)
            zipfile.add(gemfile, gemfile_path) if File.exist?(gemfile_path)
          end
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
              'role' => "${#{@role.role_name}.arn}",
              'layers' => ['${gemLayer.arn}'],
              'environment' => {
                'variables' => @env_vars.merge(
                  {
                    'GEM_PATH' => '/opt/ruby/3.2.0'
                  }
                )
              }
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
