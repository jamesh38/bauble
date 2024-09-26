# frozen_string_literal: true

module Bauble
  module Cli
    # cli logger
    module Logger
      class << self
        def log(message)
          puts "[ Bauble ] #{message}"
        end

        def pulumi(message)
          puts "[ Pulumi ] #{message}"
        end

        def nl
          puts "\n"
        end

        def debug(message)
          puts "[ Bauble Debug ] #{message}" if ENV['BAUBLE_DEBUG']
        end

        def logo
          puts <<-LOGO

          ██████╗  █████╗ ██╗   ██╗██████╗ ██╗     ███████╗
          ██╔══██╗██╔══██╗██║   ██║██╔══██╗██║     ██╔════╝
          ██████╔╝███████║██║   ██║██████╔╝██║     █████╗
          ██╔══██╗██╔══██║██║   ██║██╔══██╗██║     ██╔══╝
          ██████╔╝██║  ██║╚██████╔╝██████╔╝███████╗███████╗
          ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝ v#{Bauble::VERSION}

          LOGO
        end
      end
    end
  end
end
