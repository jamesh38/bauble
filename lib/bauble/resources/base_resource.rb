module Bauble
  module Resources
    # Base resource
    class BaseResource
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
