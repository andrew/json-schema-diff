# frozen_string_literal: true

require "json"
require "json-schema"
require "optparse"
require_relative "diff/version"
require_relative "diff/cli"
require_relative "diff/schema_parser"
require_relative "diff/comparer"
require_relative "diff/formatter"

# JSON Schema Diff provides semantic diffing capabilities for JSON files using JSON Schema metadata.
#
# This gem allows you to compare two JSON files and get a rich diff output that is guided by
# a JSON Schema, providing type information, field metadata, and structured change detection.
#
# @example Basic usage
#   Json::Schema::Diff::CLI.start(['schema.json', 'old.json', 'new.json'])
#
# @example Programmatic usage
#   schema = Json::Schema::Diff::SchemaParser.new('schema.json')
#   comparer = Json::Schema::Diff::Comparer.new(schema)
#   diff = comparer.compare(old_data, new_data)
#   formatter = Json::Schema::Diff::Formatter.new('pretty')
#   puts formatter.format(diff)
module Json
  module Schema
    # The Diff module contains all functionality for JSON Schema-guided diffing
    module Diff
      # Base error class for all JSON Schema Diff errors
      class Error < StandardError; end
    end
  end
end
