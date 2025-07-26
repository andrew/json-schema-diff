# frozen_string_literal: true

module Json
  module Schema
    module Diff
      class CLI
        def self.start(args)
          new.run(args)
        end

        def run(args)
          options = parse_options(args)
          
          if args.length != 3
            puts "Usage: json-schema-diff [OPTIONS] SCHEMA OLD_JSON NEW_JSON"
            puts "Try 'json-schema-diff --help' for more information."
            exit 1
          end

          schema_file, old_file, new_file = args

          begin
            schema = SchemaParser.new(schema_file)
            comparer = Comparer.new(schema, options[:ignore_fields] || [])
            
            old_json = JSON.parse(File.read(old_file))
            new_json = JSON.parse(File.read(new_file))
            
            diff_result = comparer.compare(old_json, new_json)
            
            formatter = Formatter.new(options[:format], options[:color])
            puts formatter.format(diff_result)
          rescue JSON::ParserError => e
            puts "Error parsing JSON: #{e.message}"
            exit 1
          rescue Errno::ENOENT => e
            puts "File not found: #{e.message}"
            exit 1
          rescue Error => e
            puts "Error: #{e.message}"
            exit 1
          end
        end

        private

        def parse_options(args)
          options = {
            format: "pretty",
            color: true,
            ignore_fields: []
          }

          parser = OptionParser.new do |opts|
            opts.banner = "Usage: json-schema-diff [OPTIONS] SCHEMA OLD_JSON NEW_JSON"
            opts.separator ""
            opts.separator "Compare two JSON files using a JSON Schema to guide and annotate the diff output."
            opts.separator ""
            opts.separator "Arguments:"
            opts.separator "  SCHEMA      Path to JSON Schema file"
            opts.separator "  OLD_JSON    Path to first JSON file (baseline)"
            opts.separator "  NEW_JSON    Path to second JSON file (comparison)"
            opts.separator ""
            opts.separator "Options:"

            opts.on("-f", "--format FORMAT", ["pretty", "json"], 
                    "Output format (pretty, json)") do |format|
              options[:format] = format
            end

            opts.on("-i", "--ignore-fields FIELDS", Array,
                    "Comma-separated list of field paths to ignore") do |fields|
              options[:ignore_fields] = fields
            end

            opts.on("--[no-]color", "Enable/disable colored output (default: enabled)") do |color|
              options[:color] = color
            end

            opts.on("-h", "--help", "Show this help message") do
              puts opts
              exit 0
            end

            opts.on("-v", "--version", "Show version") do
              puts "json-schema-diff #{VERSION}"
              exit 0
            end
          end

          parser.parse!(args)
          options
        rescue OptionParser::InvalidOption => e
          puts "Error: #{e.message}"
          puts "Try 'json-schema-diff --help' for more information."
          exit 1
        end
      end
    end
  end
end