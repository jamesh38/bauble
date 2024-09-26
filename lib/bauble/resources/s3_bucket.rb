# frozen_string_literal: true

require_relative 'base_resource'

# bauble bucket to upload assets
module Bauble
  module Resources
    # S3 bucket
    class S3Bucket < BaseResource
      attr_accessor :bucket_name, :versioning

      def initialize(stack, bucket_name: 'bauble-bucket')
        super(stack)
        @bucket_name = bucket_name
      end

      def synthesize
        {
          @bucket_name => {
            'type' => 'aws:s3:Bucket',
            'properties' => {
              'bucket' => @bucket_name
            }
          }
        }
      end
    end
  end
end
