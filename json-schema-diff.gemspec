# frozen_string_literal: true

require_relative "lib/json/schema/diff/version"

Gem::Specification.new do |spec|
  spec.name = "json-schema-diff"
  spec.version = Json::Schema::Diff::VERSION
  spec.authors = ["Andrew Nesbitt"]
  spec.email = ["andrewnez@gmail.com"]

  spec.summary = "Semantic diff for JSON files using JSON Schema metadata"
  spec.description = "A Ruby gem that performs semantic diffs between JSON files, using JSON Schema to guide and annotate the diff output with type information, field metadata, and structured change detection."
  spec.homepage = "https://github.com/andrew/json-schema-diff"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andrew/json-schema-diff"
  spec.metadata["changelog_uri"] = "https://github.com/andrew/json-schema-diff/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

end
