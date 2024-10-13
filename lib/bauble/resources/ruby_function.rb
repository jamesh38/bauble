# frozen_string_literal: true

require_relative 'resource'

# Ruby function
module Bauble
  module Resources
    # a ruby lambda function
    class RubyFunction < Resource
      attr_accessor :handler, :name, :role, :function_url, :env_vars, :layers, :timeout, :memory_size,
                    :reserved_concurrent_executions, :vpc_config

      def initialize(app, **kwargs)
        super(app)
        @name = kwargs[:name]
        @handler = kwargs[:handler]
        @role = kwargs[:role]
        @layers = kwargs.fetch(:layers, [])
        @function_url = kwargs.fetch(:function_url, false)
        @env_vars = kwargs.fetch(:env_vars, {})
        @timeout = kwargs.fetch(:timeout, 30) # default to 30 seconds
        @memory_size = kwargs.fetch(:memory_size, 128) # default to 128 MB
        @reserved_concurrent_executions = kwargs.fetch(:reserved_concurrent_executions, nil) # no limit by default
        @vpc_config = kwargs.fetch(:vpc_config, nil) # VPC config is optional
      end

      def bundle
        true
      end

      def synthesize
        template = function_hash
        template.merge!(function_url_template_addon) if @function_url
        template
      end

      private

      def function_hash
        {
          @name => {
            'type' => 'aws:lambda:Function',
            'name' => resource_name(@name),
            'properties' => {
              'name' => resource_name(@name),
              'handler' => @handler,
              'runtime' => 'ruby3.2',
              'code' => {
                'fn::fileArchive' => "#{@app.config.asset_dir}/shared_app_code/#{@app.shared_code_hash}"
              },
              'role' => "${#{@role.name}.arn}",
              'layers' => gem_layers,
              'environment' => {
                'variables' => @env_vars.merge(
                  {
                    'GEM_PATH' => '/opt/ruby/3.2.0'
                  }
                )
              },
              'timeout' => @timeout,
              'memorySize' => @memory_size,
              'reservedConcurrentExecutions' => @reserved_concurrent_executions,
              'vpcConfig' => if @vpc_config
                               {
                                 'subnetIds' => @vpc_config[:subnet_ids],
                                 'securityGroupIds' => @vpc_config[:security_group_ids]
                               }
                             else
                               nil
                             end
            }.compact
          }
        }
      end

      def gem_layers
        all_layers = layers.dup
        all_layers << '${gemLayer.arn}' unless @app.config.skip_gem_layer
        all_layers
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
