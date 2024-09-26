# frozen_string_literal: true

module Bauble
  module Cli
    # cli logger
    module Logger
      class << self
        def log(message)
          puts "[ Bauble ] #{message}"
        end
      end
    end
  end
end
