module Bauble
  module Resources
    # Base resource
    class BaseResource
      def initialize(app)
        app.add_resource(self)
      end
    end
  end
end
