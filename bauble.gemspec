# frozen_string_literal: true

require_relative 'lib/bauble/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = 'bauble_core'
  spec.version = Bauble::VERSION
  spec.authors = ['James Hoegerl']
  spec.email = ['james-hoegerl@pluralsight.com']

  spec.summary = 'Deploy Ruby-based AWS Lambda functions easily.'
  spec.description = 'Bauble is a gem designed to simplify the deployment of your Ruby-based AWS Lambda functions. It
      provides a streamlined and efficient process, ensuring that your functions are deployed quickly and correctly.'
  spec.homepage = 'https://github.com/la-jamesh/bauble'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/la-jamesh/bauble'
  spec.metadata['changelog_uri'] = 'https://github.com/la-jamesh/bauble'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile demo_app/ .tool-versions
                          .rubocop.yml Rakefile .rspec])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'colorize', '~> 1.1.0'
  spec.add_dependency 'thor', '~> 1.3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
