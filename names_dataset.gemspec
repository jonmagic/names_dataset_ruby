# frozen_string_literal: true

require_relative "lib/names_dataset/version"

Gem::Specification.new do |spec|
  spec.name = "names_dataset"
  spec.version = NamesDataset::VERSION
  spec.authors = ["Jonathan Hoyt"]
  spec.email = ["jonmagic@gmail.com"]

  spec.summary = "The Ruby library for first and last names."
  spec.description = "Use this Rubygem if you need a comprehensive list of first and last names and metadata."
  spec.homepage = "https://github.com/jonmagic/names_dataset_ruby"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/jonmagic/names_dataset_ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "iso_country_codes", "~> 0.7.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
