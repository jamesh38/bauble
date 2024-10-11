# frozen_string_literal: true

require_relative 'resource'

# bauble bucket to upload assets
module Bauble
  module Resources
    # S3 bucket
    class S3Bucket < Resource
      attr_accessor :bucket_name, :force_destroy

      def initialize(app, bucket_name: 'bauble-bucket', force_destroy: false)
        super(app)
        @bucket_name = bucket_name
        @force_destroy = force_destroy
      end

      def synthesize
        {
          @bucket_name => {
            'type' => 'aws:s3:Bucket',
            'properties' => {
              'bucket' => @bucket_name,
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
