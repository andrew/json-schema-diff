# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
