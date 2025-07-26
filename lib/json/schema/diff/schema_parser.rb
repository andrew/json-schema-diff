# frozen_string_literal: true

module Json
  module Schema
    module Diff
      # Parses and validates JSON Schema files, extracting field metadata for diff guidance
      #
      # This class handles loading JSON Schema files, validating their structure,
      # and providing methods to extract field information and detect noisy fields.
      class SchemaParser
        # @return [Hash] The parsed JSON Schema
        attr_reader :schema

        # Initialize a new SchemaParser with a JSON Schema file
        #
        # @param schema_file [String] Path to the JSON Schema file
        # @param validate_schema [Boolean] Whether to validate the schema structure (default: true)
        # @raise [Error] If the schema file is invalid or not found
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

        # Validates JSON data against the schema
        #
        # Performs basic structural validation to ensure JSON data types match schema expectations
        # and required fields are present.
        #
        # @param json_data [Object] The JSON data to validate
        # @return [Boolean] True if validation passes
        # @raise [Error] If validation fails
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

        # Gets field information from the schema for a given path
        #
        # @param path [String] Dot-separated path to the field (e.g., "user.profile.name")
        # @return [Hash] Field information including type, title, description, format, enum, and read_only
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

        # Determines if a field is considered "noisy" and should potentially be ignored
        #
        # Noisy fields are those that change frequently but aren't meaningful for comparison,
        # such as timestamps, UUIDs, or fields marked as readOnly in the schema.
        #
        # @param path [String] Dot-separated path to the field
        # @param value [Object] The field value
        # @return [Boolean] True if the field is considered noisy
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

        # Validates that the schema has basic JSON Schema structure
        #
        # @return [void]
        # @raise [Error] If the schema is missing basic structure
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

        # Traverses the schema following a path to find field-specific schema information
        #
        # @param path_parts [Array<String>] Array of path components
        # @return [Hash, nil] Schema for the field at the path, or nil if not found
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