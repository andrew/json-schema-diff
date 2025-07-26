# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-01-26

### Added

- JSON Schema validation capabilities with `json-schema` gem dependency
- New CLI options for validation control:
  - `--[no-]validate` for JSON Schema format validation (enabled by default)
  - `--[no-]validate-json` for JSON content validation against schema (disabled by default)
- Comprehensive error handling for invalid schemas and JSON validation failures
- Schema structure validation with clear error messages for malformed schemas
- Type checking validation ensuring JSON data types match schema expectations
- Required field validation for object schemas
- Fallback validation approach for complex schemas with external references

### Changed

- Updated `json-schema` dependency to version ~> 5.0 for improved performance and compatibility
- Removed `bigdecimal` dependency (no longer needed with json-schema v5)
- Enhanced error messages with specific validation failure details

## [0.1.0] - 2025-01-26

### Added

- Initial release of json-schema-diff gem
- Schema-guided JSON diffing with metadata extraction from JSON Schema
- Support for JSON Schema properties: type, title, description, format, enum, readOnly
- Multiple output formats: pretty colorized output and machine-readable JSON
- Smart noisy field detection (timestamps, UUIDs, readOnly fields)
- Custom field filtering with --ignore-fields option for excluding specific paths
- Recursive comparison of nested objects and arrays with full path tracking
- Lightweight CLI using Ruby's built-in OptionParser (no external dependencies)
- Support for all standard JSON Schema formats (date-time, uuid, email, etc.)
- Comprehensive test suite with 100% core functionality coverage (13 tests, 58 assertions)
- Professional documentation including README, CONTRIBUTING, SECURITY, and examples
- Organized examples directory with tool-specific subdirectories and version-based naming
- Official schema support for security tools:
  - Zizmor (GitHub Actions security auditor) - official v1 schema
  - Capslock (Google's Go capability analysis) - official schema
  - Generic security report template for other tools
- Real-world sample data demonstrating security finding detection and severity escalation
- CI/CD integration examples with structured JSON output for automation
- SchemaStore.org integration documentation for 600+ existing schemas
- Example outputs in README showing practical use cases and expected results
