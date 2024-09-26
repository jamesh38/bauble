# frozen_string_literal: true

module Bauble
  # Pulumi stack
  class Stack
    attr_accessor :name

    def initialize(app, name)
      @name = name
      app.add_stack(self)
    end
  end
end
