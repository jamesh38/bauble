module Bauble
  module Resources
    # Base resource
    class BaseResource
      def initialize(stack)
        stack.add_resource(self)
      end

      def synthesize
        raise 'Not implemented'
      end
    end
  end
end
