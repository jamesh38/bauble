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

        def block_log(message)
          Logger.nl
          Logger.log message
          Logger.nl
        end

        def pulumi(message)
          print "[ Pulumi ] #{message}".blue
        end

        def docker(message)
          print "[ Docker ] #{message}".magenta
        end

        def nl(times = 1)
          times.times { puts }
        end

        def debug(message)
          puts "[ Bauble DEBUG ] #{message}".orange if ENV['BAUBLE_DEBUG']
        end

        def error(message)
          nl
          puts "[ Bauble Error ] #{message}".red
          nl
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
