# frozen_string_literal: true

require File.expand_path("lib/commit_format/version", __dir__)

Gem::Specification.new do |gem|
  gem.authors = ["Tom de Bruijn"]
  gem.email = ["tom@tomdebruijn.com"]
  gem.summary = "Git commit formatter utility."
  gem.description = "Commit-format is a utility to make it easier generating " \
    "Pull Request descriptions from multiple commits."
  gem.homepage = "https://github.com/tombruijn/commit-format"
  gem.license = "MIT"

  gem.files = `git ls-files`
    .split($\) # rubocop:disable Style/SpecialGlobalVars
    .reject { |f| f.start_with?(".changesets/") }
  gem.executables << "commit-format"
  gem.name = "commit_format"
  gem.require_paths = %w[lib]
  gem.version = CommitFormat::VERSION
  gem.required_ruby_version = ">= 2.7.0"

  gem.metadata = {
    "rubygems_mfa_required" => "true",
    "bug_tracker_uri" => "https://github.com/tombruijn/commit-format/issues",
    "changelog_uri" =>
      "https://github.com/tombruijn/commit-format/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/tombruijn/commit-format"
  }

  gem.add_development_dependency "pry", "0.14.1"
  gem.add_development_dependency "rspec", "3.10.0"
  gem.add_development_dependency "rubocop", "1.25.0"
end
