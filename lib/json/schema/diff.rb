# frozen_string_literal: true

require "json"
require "json-schema"
require "optparse"
require_relative "diff/version"
require_relative "diff/cli"
require_relative "diff/schema_parser"
require_relative "diff/comparer"
require_relative "diff/formatter"

module Json
  module Schema
    module Diff
      class Error < StandardError; end
    end
  end
end
