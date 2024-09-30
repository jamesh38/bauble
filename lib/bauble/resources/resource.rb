# frozen_string_literal: true

module Bauble
  module Resources
    # Base resource
    # TODO: this should just be Resource not base resource
    class Resource
      attr_accessor :app

      def initialize(app)
        @app = app
        app.add_resource(self)
      end

      def synthesize
        raise 'Not implemented'
      end

      def bundle
        raise 'Not implemented'
      end
    end
  end
end
