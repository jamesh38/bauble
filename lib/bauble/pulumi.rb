# frozen_string_literal: true

require 'singleton'

ENV['PULUMI_HOME'] = './.bauble'
ENV['PULUMI_CONFIG_PASSPHRASE'] = ''

# pulumi wrapper
module Bauble
  # Pulumi class
  class Pulumi
    include Singleton

    def preview
      puts 'Running pulumi preview...'
      init_stack unless pulumi_initialized?
      IO.popen('pulumi preview --cwd ./.bauble 2>&1') do |io|
        io.each do |line|
          puts line
        end
      end
    end

    def init_stack
      puts 'Initializing pulumi stack...'
      `pulumi stack init --stack bauble-app --cwd ./.bauble`
    end

    def pulumi_initialized?
      # `pulumi login --local --cwd ./.bauble`
      `pulumi stack ls --cwd ./.bauble`.include?('bauble-app')
    end
  end
end
