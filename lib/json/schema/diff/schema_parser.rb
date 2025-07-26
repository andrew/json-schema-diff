# frozen_string_literal: true

module Json
  module Schema
    module Diff
      class SchemaParser
        attr_reader :schema

        def initialize(schema_file, validate_schema: true)
          @schema = JSON.parse(File.read(schema_file))
          
          if validate_schema
            validate_basic_schema_structure!
          end
        rescue JSON::ParserError => e
          raise Error, "Invalid JSON schema: #{e.message}"
        rescue Errno::ENOENT => e
          raise Error, "Schema file not found: #{e.message}"
        end

        def validate_json(json_data)
          # Simple structural validation - check if JSON structure roughly matches schema expectations
          begin
            # Basic check - if schema has type "array", JSON should be array, etc.
            if @schema["type"] == "array" && !json_data.is_a?(Array)
              raise Error, "JSON validation failed: Expected array but got #{json_data.class.name.downcase}"
            elsif @schema["type"] == "object" && !json_data.is_a?(Hash)
              raise Error, "JSON validation failed: Expected object but got #{json_data.class.name.downcase}"
            end
            
            # If we have required fields in schema, check they exist in JSON
            if @schema["required"] && json_data.is_a?(Hash)
              missing_fields = @schema["required"] - json_data.keys
              unless missing_fields.empty?
                raise Error, "JSON validation failed: Missing required fields: #{missing_fields.join(', ')}"
              end
            end
            
            true
          rescue StandardError => e
            raise Error, "JSON validation error: #{e.message}"
          end
        end

        def get_field_info(path)
          field_schema = traverse_schema(path.split('.'))
          return {} unless field_schema

          {
            type: field_schema["type"],
            title: field_schema["title"],
            description: field_schema["description"],
            format: field_schema["format"],
            enum: field_schema["enum"],
            read_only: field_schema["readOnly"] || false
          }
        end

        def is_noisy_field?(path, value)
          field_info = get_field_info(path)
          format = field_info[:format]
          
          # Check for timestamp formats
          return true if format == "date-time" || format == "date" || format == "time"
          
          # Check for UUID format
          return true if format == "uuid"
          
          # Check for fields that look like UUIDs or timestamps
          if value.is_a?(String)
            return true if value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
            return true if value.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
          end
          
          false
        end

        private

        def validate_basic_schema_structure!
          # Basic structural validation for schema
          unless @schema.is_a?(Hash)
            raise Error, "Schema must be a JSON object"
          end
          
          # Check for basic schema structure
          if @schema["type"].nil? && @schema["properties"].nil? && @schema["items"].nil?
            raise Error, "Schema appears to be missing basic JSON Schema structure (no type, properties, or items)"
          end
        end

        def traverse_schema(path_parts)
          current = @schema
          
          path_parts.each do |part|
            if current["type"] == "object" && current["properties"]
              current = current["properties"][part]
              return nil unless current
            elsif current["type"] == "array" && current["items"]
              current = current["items"]
            else
              return nil
            end
          end
          
          current
        end
      end
    end
  end
end