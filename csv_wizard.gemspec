# frozen_string_literal: true

require_relative "lib/csv_wizard/version"

Gem::Specification.new do |spec|
  spec.name = "csv_wizard"
  spec.version = CsvWizard::VERSION
  spec.authors = ["mrmalvi"]
  spec.email = ["malviyak00@gmail.com"]

  spec.license = "MIT"

  spec.summary = "CsvWizard: Import and process CSV files into ActiveRecord models."
  spec.description = "CsvWizard provides a simple framework to import CSV files into Rails models. It supports required fields, default values, row-level validation, and hooks for pre- and post-processing."
  spec.homepage      = "https://github.com/mrmalvi/csv_wizard"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = "https://github.com/mrmalvi/csv_wizard"
  spec.metadata["changelog_uri"]    = "https://github.com/mrmalvi/csv_wizard/blob/main/CHANGELOG.md"


  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "activejob", ">= 6.0"
  spec.add_dependency "csv", ">= 3.2"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency 'rspec-rails', '~> 6.0'
  spec.add_development_dependency "sqlite3", ">= 2.1"
  spec.add_dependency "logging", ">= 2.3"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      f == gemspec || f.end_with?('.gem') || f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
