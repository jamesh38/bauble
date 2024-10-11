# frozen_string_literal: true

require_relative 'resource'

# bauble bucket to upload assets
module Bauble
  module Resources
    # S3 bucket
    class S3Bucket < Resource
      attr_accessor :name, :force_destroy

      def initialize(app, name: 'bauble-bucket', force_destroy: false)
        super(app)
        @name = name
        @force_destroy = force_destroy
      end

      def synthesize
        {
          @name => {
            'type' => 'aws:s3:Bucket',
            'properties' => {
              'bucket' => resource_name(@name),
              'forceDestroy' => @force_destroy
            }
          }
        }
      end

      def bundle
        true
      end
    end
  end
end
