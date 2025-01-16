# frozen_string_literal: true

require 'net/http'
require 'thor'
require_relative '../pulumi'
require_relative '../logger'

module Bauble
  module Cli
    module Commands
      # Up command
      module New
        class << self
          def included(thor) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
            thor.class_eval do # rubocop:disable Metrics/BlockLength
              desc 'new [DESTINATION]', 'Scaffolds a new app from a GitHub repository'
              map 'new' => :new_app
              option :template, type: :string, default: 'basic-app',
                                desc: 'The template to use for the new app'

              def new_app(destination)
                github_repo = 'jamesh38/bauble'
                specific_dir = "examples/#{options[:template]}"
                dest_dir = destination ? "#{Dir.pwd}/#{destination}" : Dir.pwd
                begin
                  uri = URI("https://api.github.com/repos/#{github_repo}/contents/#{specific_dir}")
                  fetch_and_write_files(uri, dest_dir, specific_dir)
                rescue StandardError => e
                  Logger.error e.message
                  return
                end
                Logger.block_log 'New app created successfully'
              end

              no_commands do
                def fetch_and_write_files(uri, destination, specific_dir) # rubocop:disable Metrics
                  response = Net::HTTP.get_response(uri)

                  if response.is_a?(Net::HTTPSuccess)
                    files = JSON.parse(response.body)

                    files.each do |file|
                      if file['type'] == 'file'
                        next if file['name'] == 'Gemfile.lock'

                        file_uri = URI(file['download_url'])
                        file_content = Net::HTTP.get(file_uri)
                        target_path = File.join(destination, file['path'].sub(specific_dir, ''))
                        FileUtils.mkdir_p(File.dirname(target_path))
                        File.write(target_path, file_content)
                      elsif file['type'] == 'dir'
                        new_uri = URI(file['url'])
                        fetch_and_write_files(new_uri, destination, specific_dir)
                      end
                    end
                  elsif response.is_a?(Net::HTTPNotFound)
                    raise 'Failed to create new app: Unknown template'
                  else
                    raise "Failed to to create new app: #{response.message}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
