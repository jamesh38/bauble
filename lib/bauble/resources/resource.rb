# frozen_string_literal: true

module Bauble
  module Resources
    # Base resource
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

      def resource_name(base_name)
        "#{app.name}-#{base_name}-#{app.current_stack.name}"
      end
    end
  end
end
