# frozen_string_literal: true

require_relative "lib/validates_some/version"

Gem::Specification.new do |spec|
  spec.name = "validates_some"
  spec.version = ValidatesSome::VERSION
  spec.license = "MIT"
  spec.authors = ["Dimitar Apostolovski"]
  spec.email = ["d.apostolovski@protonmail.com"]
  spec.summary = "Attribute grouping for `ActiveModel` validations"
  spec.description = <<~DESCRIPTION
    `validates_some` is an extenstion to the ActiveModel validation API.

    The `validates_some` method filters declared validations for the referenced attributes. It expects that just _some_ (at least one) of the listed attributes are valid for the whole group of attributes to be considered validated.
  DESCRIPTION
  spec.homepage = "https://github.com/themetar/validates_some"
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/themetar/validates_some"
  # spec.metadata["changelog_uri"] = "TODO: Put CHANGELOG.md URL here."

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile Rakefile .rubocop])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 7.0"
end
