module Bauble
  module Resources
    # Base resource
    class BaseResource
      def initialize(app)
        app.add_resource(self)
      end

      def synthesize
        raise 'Not implemented'
      end
    end
  end
end
