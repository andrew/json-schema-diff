# frozen_string_literal: true

module Json
  module Schema
    module Diff
      class Comparer
        def initialize(schema_parser, ignore_fields = [])
          @schema_parser = schema_parser
          @ignore_fields = ignore_fields.map(&:to_s)
        end

        def compare(old_json, new_json)
          changes = []
          compare_recursive(old_json, new_json, "", changes)
          changes
        end

        private

        def compare_recursive(old_val, new_val, path, changes)
          # Skip ignored fields
          return if @ignore_fields.include?(path)

          field_info = @schema_parser.get_field_info(path)
          
          # Skip read-only fields
          return if field_info[:read_only]

          if old_val.nil? && !new_val.nil?
            add_change(changes, path, old_val, new_val, "addition", field_info)
          elsif !old_val.nil? && new_val.nil?
            add_change(changes, path, old_val, new_val, "removal", field_info)
          elsif old_val.class != new_val.class
            add_change(changes, path, old_val, new_val, "type_change", field_info)
          elsif old_val.is_a?(Hash) && new_val.is_a?(Hash)
            compare_objects(old_val, new_val, path, changes)
          elsif old_val.is_a?(Array) && new_val.is_a?(Array)
            compare_arrays(old_val, new_val, path, changes)
          elsif old_val != new_val
            add_change(changes, path, old_val, new_val, "modification", field_info)
          end
        end

        def compare_objects(old_obj, new_obj, path, changes)
          all_keys = (old_obj.keys + new_obj.keys).uniq
          
          all_keys.each do |key|
            key_path = path.empty? ? key : "#{path}.#{key}"
            compare_recursive(old_obj[key], new_obj[key], key_path, changes)
          end
        end

        def compare_arrays(old_arr, new_arr, path, changes)
          max_length = [old_arr.length, new_arr.length].max
          
          (0...max_length).each do |index|
            index_path = "#{path}[#{index}]"
            old_item = index < old_arr.length ? old_arr[index] : nil
            new_item = index < new_arr.length ? new_arr[index] : nil
            compare_recursive(old_item, new_item, index_path, changes)
          end
        end

        def add_change(changes, path, old_val, new_val, change_type, field_info)
          # Check if this is a noisy field
          is_noisy = @schema_parser.is_noisy_field?(path, old_val) || 
                     @schema_parser.is_noisy_field?(path, new_val)

          change = {
            path: path,
            old_value: old_val,
            new_value: new_val,
            change_type: change_type,
            field_info: field_info,
            is_noisy: is_noisy
          }
          
          changes << change
        end
      end
    end
  end
end