# frozen_string_literal: true

module Json
  module Schema
    module Diff
      # Formats diff results into human-readable or machine-readable output
      #
      # Supports both pretty-printed colorized output for humans and JSON output for machines.
      # Handles ANSI color codes and provides structured formatting of change information.
      class Formatter
        # ANSI color codes for terminal output
        COLORS = {
          red: "\e[31m",
          green: "\e[32m",
          yellow: "\e[33m",
          blue: "\e[34m",
          magenta: "\e[35m",
          cyan: "\e[36m",
          reset: "\e[0m"
        }.freeze

        # Initialize a new Formatter
        #
        # @param format [String] Output format - "pretty" or "json" (default: "pretty")
        # @param use_color [Boolean] Whether to use ANSI color codes (default: true)
        def initialize(format = "pretty", use_color = true)
          @format = format
          @use_color = use_color
        end

        # Formats an array of changes into the specified output format
        #
        # @param changes [Array<Hash>] Array of change objects from Comparer
        # @return [String] Formatted output string
        def format(changes)
          case @format
          when "json"
            format_json(changes)
          else
            format_pretty(changes)
          end
        end

        private

        def format_json(changes)
          JSON.pretty_generate(changes.map do |change|
            {
              path: change[:path],
              change_type: change[:change_type],
              old_value: change[:old_value],
              new_value: change[:new_value],
              field_info: change[:field_info],
              is_noisy: change[:is_noisy]
            }
          end)
        end

        def format_pretty(changes)
          return "No changes detected." if changes.empty?

          output = []
          output << colorize("JSON Schema Diff Results", :cyan, bold: true)
          output << "=" * 50
          
          # Group changes by type
          grouped = changes.group_by { |c| c[:change_type] }
          
          %w[addition removal modification type_change].each do |type|
            next unless grouped[type]
            
            output << ""
            output << colorize("#{type.upcase.tr('_', ' ')}S (#{grouped[type].length}):", type_color(type), bold: true)
            output << ""
            
            grouped[type].each do |change|
              output.concat(format_change(change))
            end
          end
          
          # Summary
          output << ""
          output << colorize("SUMMARY:", :blue, bold: true)
          output << "Total changes: #{changes.length}"
          noisy_count = changes.count { |c| c[:is_noisy] }
          output << "Noisy fields: #{noisy_count}" if noisy_count > 0
          
          output.join("\n")
        end

        def format_change(change)
          lines = []
          path = change[:path]
          field_info = change[:field_info]
          
          # Path and type info
          path_line = "  #{path}"
          if field_info[:type]
            path_line += " (#{field_info[:type]}"
            path_line += ", #{field_info[:format]}" if field_info[:format]
            path_line += ")"
          end
          path_line += colorize(" [noisy]", :yellow) if change[:is_noisy]
          lines << path_line
          
          # Title/description if available
          if field_info[:title]
            lines << "    Title: #{field_info[:title]}"
          end
          
          # Show enum values if applicable
          if field_info[:enum]
            lines << "    Allowed values: #{field_info[:enum].join(', ')}"
          end
          
          # Value changes
          case change[:change_type]
          when "addition"
            lines << "    #{colorize('+ Added:', :green)} #{format_value(change[:new_value])}"
          when "removal"
            lines << "    #{colorize('- Removed:', :red)} #{format_value(change[:old_value])}"
          when "modification", "type_change"
            lines << "    #{colorize('- Old:', :red)} #{format_value(change[:old_value])}"
            lines << "    #{colorize('+ New:', :green)} #{format_value(change[:new_value])}"
          end
          
          lines << ""
          lines
        end

        def format_value(value)
          case value
          when String
            "\"#{value}\""
          when nil
            "null"
          else
            value.to_s
          end
        end

        def type_color(type)
          case type
          when "addition" then :green
          when "removal" then :red
          when "modification" then :yellow
          when "type_change" then :magenta
          else :blue
          end
        end

        def colorize(text, color, bold: false)
          return text unless @use_color
          
          result = "#{COLORS[color]}#{text}#{COLORS[:reset]}"
          result = "\e[1m#{result}" if bold
          result
        end
      end
    end
  end
end