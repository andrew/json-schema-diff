# JSON Schema Diff

A Ruby gem that performs semantic diffs between JSON files, using JSON Schema to guide and annotate the diff output with type information, field metadata, and structured change detection.

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.2-red.svg)](https://www.ruby-lang.org/)
[![Gem Version](https://badge.fury.io/rb/json-schema-diff.svg)](https://rubygems.org/gems/json-schema-diff)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Perfect for comparing structured CLI output from security tools like zizmor and capslock across versions to highlight when security issues have been introduced or resolved.

## Features

- **Schema-guided diffing** - Uses JSON Schema metadata to provide context for changes
- **Multiple output formats** - Pretty colorized output for humans, JSON for machines
- **Smart field filtering** - Automatically detects and can ignore noisy fields (timestamps, UUIDs)
- **Read-only field support** - Respects `readOnly` schema properties
- **Nested object and array support** - Handles complex JSON structures
- **Custom field ignoring** - Ignore specific fields by path
- **Type and format information** - Shows field types, formats, and enum values from schema
- **Change categorization** - Clearly identifies additions, removals, and modifications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json-schema-diff'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install json-schema-diff
```

## Usage

### Basic Usage

```bash
json-schema-diff schema.json old.json new.json
```

### Output Formats

```bash
# Pretty colorized output (default)
json-schema-diff --format pretty schema.json old.json new.json

# Machine-readable JSON output
json-schema-diff --format json schema.json old.json new.json

# Disable colors
json-schema-diff --no-color schema.json old.json new.json
```

### Validation Options

```bash
# Enable JSON validation against schema (helps catch data format errors)
json-schema-diff --validate-json schema.json old.json new.json

# Disable schema format validation (for malformed schemas)
json-schema-diff --no-validate schema.json old.json new.json

# Both validation options
json-schema-diff --validate-json --validate schema.json old.json new.json
```

### Ignoring Fields

```bash
# Ignore specific fields (comma-separated)
json-schema-diff --ignore-fields timestamp,scan_id,duration_ms schema.json old.json new.json
```

### CLI Options

```bash
# Show help
json-schema-diff --help

# Show version
json-schema-diff --version

# All options
json-schema-diff [OPTIONS] SCHEMA OLD_JSON NEW_JSON

Options:
  -f, --format FORMAT          Output format (pretty, json)
  -i, --ignore-fields FIELDS   Comma-separated list of field paths to ignore
      --[no-]color             Enable/disable colored output (default: enabled)
      --[no-]validate          Enable/disable JSON Schema format validation (default: enabled)
      --[no-]validate-json     Enable/disable JSON validation against schema (default: disabled)
  -h, --help                   Show help message
  -v, --version                Show version
```

### Example Output

```
JSON Schema Diff Results
==================================================

ADDITIONS (1):

  issues[3] (object)
    + Added: {"id":"ZIZ004","severity":"critical","category":"crypto",...}

REMOVALS (1):

  issues[2] (object)
    Title: Security Issue
    + Removed: {"id":"ZIZ003","severity":"medium","category":"misc",...}

MODIFICATIONS (2):

  metadata.version (string)
    Title: Tool Version
    - Old: "1.2.0"
    + New: "1.3.0"

  summary.by_severity.critical (integer)
    Title: Critical Issues
    - Old: 1
    + New: 2

SUMMARY:
Total changes: 4
Noisy fields: 2
```

### Ruby API

```ruby
require 'json/schema/diff'

# Parse schema
schema = Json::Schema::Diff::SchemaParser.new('schema.json')

# Create comparer with optional ignore fields
comparer = Json::Schema::Diff::Comparer.new(schema, ['timestamp', 'scan_id'])

# Load and compare JSON files
old_json = JSON.parse(File.read('old.json'))
new_json = JSON.parse(File.read('new.json'))

changes = comparer.compare(old_json, new_json)

# Format results
formatter = Json::Schema::Diff::Formatter.new('pretty', true)
puts formatter.format(changes)
```

## Schema Features

### Supported JSON Schema Properties

- **type** - Field data type (string, integer, object, array, etc.)
- **title** - Human-readable field name
- **description** - Field description
- **format** - Field format (date-time, uuid, email, etc.)
- **enum** - Allowed values for the field
- **readOnly** - Fields marked as read-only are ignored in diffs

### Noisy Field Detection

The gem automatically detects potentially noisy fields based on:

- **Format hints**: `date-time`, `date`, `time`, `uuid` formats
- **Value patterns**: UUID strings, ISO timestamp strings
- **Schema annotations**: Fields marked as `readOnly`

### Example Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Security Report Schema",
  "type": "object",
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "tool": {
          "type": "string",
          "title": "Tool Name",
          "enum": ["zizmor", "capslock", "semgrep"]
        },
        "timestamp": {
          "type": "string",
          "format": "date-time",
          "readOnly": true
        }
      }
    },
    "issues": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "severity": {
            "type": "string",
            "enum": ["critical", "high", "medium", "low"]
          }
        }
      }
    }
  }
}
```

## Use Cases

### Security Tool Comparison

Compare security scan results across tool versions:

```bash
# Compare zizmor audit results (official schema)
# See: https://github.com/zizmorcore/zizmor
json-schema-diff examples/zizmor/zizmor.schema.json zizmor-v0.1.0.json zizmor-v0.2.0.json
```

**Example Output:**
```
JSON Schema Diff Results
==================================================

ADDITIONS (1):

  [2]
    + Added: {"ident":"hardcoded-credentials","desc":"Hardcoded credentials detected",...}

MODIFICATIONS (2):

  [1].determinations.confidence
    - Old: "Medium"
    + New: "High"

  [1].determinations.severity  
    - Old: "Medium"
    + New: "High"

SUMMARY:
Total changes: 3
```

```bash
# Compare capslock capability analysis  
# See: https://github.com/google/capslock
json-schema-diff examples/capslock/capslock.schema.json capslock-v0.5.0.json capslock-v0.6.0.json
```

**Example Output:**
```
JSON Schema Diff Results
==================================================

ADDITIONS (3):

  capability_info[2]
    + Added: {"package_name":"github.com/example/myapp/crypto","capability":"CAPABILITY_ARBITRARY_EXECUTION",...}

  module_info[2]  
    + Added: {"path":"github.com/suspicious/lib","version":"v1.2.3"}

  package_info[2]
    + Added: {"path":"github.com/example/myapp/crypto","ignored_files":[]}

MODIFICATIONS (2):

  module_info[0].version
    - Old: "v1.0.0"
    + New: "v1.1.0"

  module_info[1].version
    - Old: "v1.8.0" 
    + New: "v1.8.1"

SUMMARY:
Total changes: 5
```

### CI/CD Integration

Integrate into your CI pipeline to track security improvements:

```bash
#!/bin/bash
# Run zizmor security scan
zizmor --format json > zizmor-current.json

# Compare with previous scan using official schema
if [ -f zizmor-previous.json ]; then
  json-schema-diff examples/zizmor/zizmor.schema.json zizmor-previous.json zizmor-current.json --format json > security-diff.json
fi

# Archive current scan for next comparison
cp zizmor-current.json zizmor-previous.json

# Run capslock capability analysis
capslock -output json > capslock-current.json
if [ -f capslock-previous.json ]; then
  json-schema-diff examples/capslock/capslock.schema.json capslock-previous.json capslock-current.json --format json > capability-diff.json
fi
cp capslock-current.json capslock-previous.json
```

**Example JSON Output for Automation:**
```json
[
  {
    "path": "[1].determinations.severity",
    "change_type": "modification", 
    "old_value": "Medium",
    "new_value": "High",
    "field_info": {},
    "is_noisy": false
  },
  {
    "path": "[2]",
    "change_type": "addition",
    "old_value": null,
    "new_value": {
      "ident": "hardcoded-credentials",
      "desc": "Hardcoded credentials detected",
      "determinations": {
        "confidence": "High",
        "severity": "High"
      }
    },
    "field_info": {},
    "is_noisy": false
  }
]
```

### Configuration Monitoring

Track changes in complex configuration files using SchemaStore schemas:

```bash
# Monitor package.json changes
curl -s https://json.schemastore.org/package.json > package.schema.json
json-schema-diff --ignore-fields version package.schema.json old-package.json new-package.json
```

**Example Output:**
```
JSON Schema Diff Results
==================================================

ADDITIONS (1):

  dependencies.lodash (string)
    Title: Dependency
    + Added: "^4.17.21"

MODIFICATIONS (1):

  scripts.test (string)
    Title: Script Command
    - Old: "jest"
    + New: "jest --coverage"

SUMMARY:
Total changes: 2
```

```bash
# Track GitHub Actions workflow changes
curl -s https://json.schemastore.org/github-workflow.json > workflow.schema.json  
json-schema-diff workflow.schema.json old-workflow.json new-workflow.json

# Monitor Docker Compose changes
curl -s https://json.schemastore.org/docker-compose.yml > compose.schema.json
json-schema-diff compose.schema.json old-compose.json new-compose.json
```

### Development Workflow Analysis

Compare development tool outputs with proper schema context:

```bash
# ESLint configuration changes
curl -s https://json.schemastore.org/eslintrc.json > eslint.schema.json
json-schema-diff eslint.schema.json old-eslintrc.json new-eslintrc.json

# TypeScript configuration tracking  
curl -s https://json.schemastore.org/tsconfig.json > tsconfig.schema.json
json-schema-diff tsconfig.schema.json old-tsconfig.json new-tsconfig.json
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then:

```bash
# Run tests
rake test

# Run with example files
bundle exec exe/json-schema-diff examples/security-report.schema.json examples/old-report.json examples/new-report.json

# Install locally
bundle exec rake install
```

## Examples

The `examples/` directory contains organized examples for different security tools:

### Tool-Specific Examples

- **`examples/zizmor/`** - [Zizmor](https://github.com/zizmorcore/zizmor) GitHub Actions security auditor
  - `zizmor.schema.json` - Official zizmor JSON output schema (v1)  
  - `zizmor-v0.1.0.json` / `zizmor-v0.2.0.json` - Sample audit reports across versions

- **`examples/capslock/`** - [Capslock](https://github.com/google/capslock) Go capability analysis
  - `capslock.schema.json` - Google's Capslock capability analysis schema
  - `capslock-v0.5.0.json` / `capslock-v0.6.0.json` - Sample capability reports across versions

- **`examples/generic/`** - Generic security tool template
  - `security-report.schema.json` - Generic security analysis reports schema
  - `report-v1.2.0.json` / `report-v1.3.0.json` - Sample security reports

### Try the Examples

```bash
# Zizmor security audit comparison (official schema)
json-schema-diff examples/zizmor/zizmor.schema.json examples/zizmor/zizmor-v0.1.0.json examples/zizmor/zizmor-v0.2.0.json

# Capslock capability analysis
json-schema-diff examples/capslock/capslock.schema.json examples/capslock/capslock-v0.5.0.json examples/capslock/capslock-v0.6.0.json

# Generic security tool comparison  
json-schema-diff examples/generic/security-report.schema.json examples/generic/report-v1.2.0.json examples/generic/report-v1.3.0.json
```

### Using Existing Schemas

The gem works with any valid JSON Schema. You can use schemas from:

- **[SchemaStore.org](https://www.schemastore.org/)** - Hundreds of schemas for popular tools and configurations
- **Tool documentation** - Many CLI tools provide JSON schemas for their output
- **Custom schemas** - Create your own schemas for proprietary formats

For example, with SchemaStore schemas:

```bash
# Compare GitHub Actions workflows
curl -o github-workflow.schema.json https://json.schemastore.org/github-workflow.json
json-schema-diff github-workflow.schema.json old-workflow.yml new-workflow.yml

# Compare package.json files  
curl -o package.schema.json https://json.schemastore.org/package.json
json-schema-diff package.schema.json old-package.json new-package.json

# Compare Docker Compose files
curl -o compose.schema.json https://json.schemastore.org/docker-compose.yml
json-schema-diff compose.schema.json old-compose.yml new-compose.yml
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/andrew/json-schema-diff>.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes
4. Add tests for your changes
5. Ensure all tests pass (`rake test`)
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Security

For security issues, please see our [Security Policy](SECURITY.md).

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes and releases.

## Code of Conduct

Everyone interacting in the json-schema-diff project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
