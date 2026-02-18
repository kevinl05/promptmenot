# frozen_string_literal: true

require_relative "lib/promptmenot/version"

Gem::Specification.new do |spec|
  spec.name = "promptmenot"
  spec.version = Promptmenot::VERSION
  spec.authors = ["promptmenot contributors"]
  spec.email = []

  spec.summary = "Detect and sanitize prompt injection attacks in user-submitted text"
  spec.description = "A Ruby on Rails gem that detects and sanitizes prompt injection attacks. " \
                     "Protects against direct injection (users hacking your LLMs via form inputs) " \
                     "and indirect injection (malicious prompts stored for other LLMs to scrape)."
  spec.homepage = "https://github.com/kevinl05/promptmenot"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?("spec/", "test/", ".git", ".github", "bin/")
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
end
