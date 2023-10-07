# frozen_string_literal: true

require_relative "lib/stomp/version"

Gem::Specification.new do |spec|
  spec.name = "stomp"
  spec.version = Stomp::VERSION
  spec.authors = ["Romain Sanson"]
  spec.email = ["romain.sanson@hey.com"]

  spec.summary     = "A library for handling multi-step forms in Rails applications."
  spec.description = "Stomp provides a set of modules and controllers to make it easier to create multi-step forms in Ruby on Rails applications. It offers built-in state management and step-by-step validation to enhance the user experience."
  spec.homepage    = "https://github.com/ghbozz/stomp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"  # ou votre propre serveur de gem si vous en avez un

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ghbozz/stomp"
  spec.metadata["changelog_uri"] = "https://github.com/ghbozz/stomp/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'activesupport'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
