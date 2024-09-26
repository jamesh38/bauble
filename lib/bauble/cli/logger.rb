# frozen_string_literal: true

require 'colorize'

module Bauble
  module Cli
    # cli logger
    module Logger
      class << self
        def log(message)
          print "[ Bauble ] #{message}".green
        end

        def pulumi(message)
          print "[ Pulumi ] #{message}".blue
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
