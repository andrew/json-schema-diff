# frozen_string_literal: true

require "test_helper"
require "tempfile"

class Json::Schema::TestDiff < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Json::Schema::Diff::VERSION
  end

  def test_schema_parser_loads_valid_schema
    schema_content = {
      "type" => "object",
      "properties" => {
        "name" => { "type" => "string", "title" => "Full Name" },
        "age" => { "type" => "integer" }
      }
    }
    
    with_temp_file(schema_content.to_json) do |schema_file|
      parser = Json::Schema::Diff::SchemaParser.new(schema_file)
      assert_equal schema_content, parser.schema
    end
  end

  def test_schema_parser_extracts_field_info
    schema_content = {
      "type" => "object",
      "properties" => {
        "name" => { 
          "type" => "string", 
          "title" => "Full Name",
          "description" => "The person's full name"
        },
        "email" => { 
          "type" => "string", 
          "format" => "email"
        },
        "role" => {
          "type" => "string",
          "enum" => ["admin", "user", "guest"]
        },
        "metadata" => {
          "type" => "object",
          "properties" => {
            "created_at" => {
              "type" => "string",
              "format" => "date-time",
              "readOnly" => true
            }
          }
        }
      }
    }
    
    with_temp_file(schema_content.to_json) do |schema_file|
      parser = Json::Schema::Diff::SchemaParser.new(schema_file)
      
      name_info = parser.get_field_info("name")
      assert_equal "string", name_info[:type]
      assert_equal "Full Name", name_info[:title]
      assert_equal "The person's full name", name_info[:description]
      
      email_info = parser.get_field_info("email")
      assert_equal "email", email_info[:format]
      
      role_info = parser.get_field_info("role")
      assert_equal ["admin", "user", "guest"], role_info[:enum]
      
      created_info = parser.get_field_info("metadata.created_at")
      assert_equal true, created_info[:read_only]
      assert_equal "date-time", created_info[:format]
    end
  end

  def test_schema_parser_detects_noisy_fields
    schema_content = {
      "type" => "object",
      "properties" => {
        "id" => { "type" => "string", "format" => "uuid" },
        "created_at" => { "type" => "string", "format" => "date-time" }
      }
    }
    
    with_temp_file(schema_content.to_json) do |schema_file|
      parser = Json::Schema::Diff::SchemaParser.new(schema_file)
      
      assert parser.is_noisy_field?("id", "123e4567-e89b-12d3-a456-426614174000")
      assert parser.is_noisy_field?("created_at", "2023-01-01T12:00:00Z")
      refute parser.is_noisy_field?("name", "John Doe")
    end
  end

  def test_comparer_detects_additions
    schema = create_test_schema
    comparer = Json::Schema::Diff::Comparer.new(schema)
    
    old_json = { "name" => "John" }
    new_json = { "name" => "John", "age" => 30 }
    
    changes = comparer.compare(old_json, new_json)
    
    assert_equal 1, changes.length
    change = changes.first
    assert_equal "age", change[:path]
    assert_equal "addition", change[:change_type]
    assert_nil change[:old_value]
    assert_equal 30, change[:new_value]
  end

  def test_comparer_detects_removals
    schema = create_test_schema
    comparer = Json::Schema::Diff::Comparer.new(schema)
    
    old_json = { "name" => "John", "age" => 30 }
    new_json = { "name" => "John" }
    
    changes = comparer.compare(old_json, new_json)
    
    assert_equal 1, changes.length
    change = changes.first
    assert_equal "age", change[:path]
    assert_equal "removal", change[:change_type]
    assert_equal 30, change[:old_value]
    assert_nil change[:new_value]
  end

  def test_comparer_detects_modifications
    schema = create_test_schema
    comparer = Json::Schema::Diff::Comparer.new(schema)
    
    old_json = { "name" => "John", "age" => 30 }
    new_json = { "name" => "Jane", "age" => 25 }
    
    changes = comparer.compare(old_json, new_json)
    
    assert_equal 2, changes.length
    
    name_change = changes.find { |c| c[:path] == "name" }
    assert_equal "modification", name_change[:change_type]
    assert_equal "John", name_change[:old_value]
    assert_equal "Jane", name_change[:new_value]
    
    age_change = changes.find { |c| c[:path] == "age" }
    assert_equal "modification", age_change[:change_type]
    assert_equal 30, age_change[:old_value]
    assert_equal 25, age_change[:new_value]
  end

  def test_comparer_handles_nested_objects
    schema_content = {
      "type" => "object",
      "properties" => {
        "user" => {
          "type" => "object",
          "properties" => {
            "name" => { "type" => "string" },
            "contact" => {
              "type" => "object",
              "properties" => {
                "email" => { "type" => "string" }
              }
            }
          }
        }
      }
    }
    
    with_temp_file(schema_content.to_json) do |schema_file|
      schema = Json::Schema::Diff::SchemaParser.new(schema_file)
      comparer = Json::Schema::Diff::Comparer.new(schema)
      
      old_json = { "user" => { "name" => "John", "contact" => { "email" => "john@old.com" } } }
      new_json = { "user" => { "name" => "John", "contact" => { "email" => "john@new.com" } } }
      
      changes = comparer.compare(old_json, new_json)
      
      assert_equal 1, changes.length
      change = changes.first
      assert_equal "user.contact.email", change[:path]
      assert_equal "modification", change[:change_type]
      assert_equal "john@old.com", change[:old_value]
      assert_equal "john@new.com", change[:new_value]
    end
  end

  def test_comparer_handles_arrays
    schema_content = {
      "type" => "object",
      "properties" => {
        "tags" => {
          "type" => "array",
          "items" => { "type" => "string" }
        }
      }
    }
    
    with_temp_file(schema_content.to_json) do |schema_file|
      schema = Json::Schema::Diff::SchemaParser.new(schema_file)
      comparer = Json::Schema::Diff::Comparer.new(schema)
      
      old_json = { "tags" => ["ruby", "json"] }
      new_json = { "tags" => ["ruby", "diff", "json"] }
      
      changes = comparer.compare(old_json, new_json)
      
      assert_equal 2, changes.length
      
      # Item at index 1 changed from "json" to "diff"
      change1 = changes.find { |c| c[:path] == "tags[1]" }
      assert_equal "modification", change1[:change_type]
      assert_equal "json", change1[:old_value]
      assert_equal "diff", change1[:new_value]
      
      # Item added at index 2
      change2 = changes.find { |c| c[:path] == "tags[2]" }
      assert_equal "addition", change2[:change_type]
      assert_nil change2[:old_value]
      assert_equal "json", change2[:new_value]
    end
  end

  def test_comparer_ignores_specified_fields
    schema = create_test_schema
    comparer = Json::Schema::Diff::Comparer.new(schema, ["age"])
    
    old_json = { "name" => "John", "age" => 30 }
    new_json = { "name" => "Jane", "age" => 25 }
    
    changes = comparer.compare(old_json, new_json)
    
    assert_equal 1, changes.length
    change = changes.first
    assert_equal "name", change[:path]
  end

  def test_comparer_ignores_readonly_fields
    schema_content = {
      "type" => "object",
      "properties" => {
        "name" => { "type" => "string" },
        "created_at" => { 
          "type" => "string", 
          "format" => "date-time",
          "readOnly" => true
        }
      }
    }
    
    with_temp_file(schema_content.to_json) do |schema_file|
      schema = Json::Schema::Diff::SchemaParser.new(schema_file)
      comparer = Json::Schema::Diff::Comparer.new(schema)
      
      old_json = { "name" => "John", "created_at" => "2023-01-01T12:00:00Z" }
      new_json = { "name" => "Jane", "created_at" => "2023-01-02T12:00:00Z" }
      
      changes = comparer.compare(old_json, new_json)
      
      assert_equal 1, changes.length
      change = changes.first
      assert_equal "name", change[:path]
    end
  end

  def test_formatter_json_output
    changes = [
      {
        path: "name",
        change_type: "modification",
        old_value: "John",
        new_value: "Jane",
        field_info: { type: "string" },
        is_noisy: false
      }
    ]
    
    formatter = Json::Schema::Diff::Formatter.new("json", false)
    output = formatter.format(changes)
    
    parsed = JSON.parse(output)
    assert_equal 1, parsed.length
    assert_equal "name", parsed.first["path"]
    assert_equal "modification", parsed.first["change_type"]
  end

  def test_formatter_pretty_output
    changes = [
      {
        path: "name",
        change_type: "modification",
        old_value: "John",
        new_value: "Jane",
        field_info: { type: "string", title: "Full Name" },
        is_noisy: false
      }
    ]
    
    formatter = Json::Schema::Diff::Formatter.new("pretty", false)
    output = formatter.format(changes)
    
    assert_includes output, "MODIFICATIONS"
    assert_includes output, "name (string)"
    assert_includes output, "Title: Full Name"
    assert_includes output, "- Old: \"John\""
    assert_includes output, "+ New: \"Jane\""
  end

  private

  def create_test_schema
    schema_content = {
      "type" => "object",
      "properties" => {
        "name" => { "type" => "string", "title" => "Full Name" },
        "age" => { "type" => "integer" }
      }
    }
    
    Tempfile.create(["schema", ".json"]) do |file|
      file.write(schema_content.to_json)
      file.flush
      return Json::Schema::Diff::SchemaParser.new(file.path)
    end
  end

  def with_temp_file(content)
    Tempfile.create(["test", ".json"]) do |file|
      file.write(content)
      file.flush
      yield file.path
    end
  end
end
