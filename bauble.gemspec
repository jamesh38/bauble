# frozen_string_literal: true

require_relative 'lib/bauble/version'

Gem::Specification.new do |spec|
  spec.name = 'bauble'
  spec.version = Bauble::VERSION
  spec.authors = ['James Hoegerl']
  spec.email = ['james-hoegerl@pluralsight.com']

  spec.summary = 'A gem to help you deploy Ruby based AWS Lambda functions.'
  spec.description = 'A gem to help you deploy Ruby based AWS Lambda functions.'
  spec.homepage = 'https://github.com/la-jamesh/bauble'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/la-jamesh/bauble'
  spec.metadata['changelog_uri'] = 'https://github.com/la-jamesh/bauble'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'colorize'
  spec.add_dependency 'rubyzip'
  spec.add_dependency 'thor'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
