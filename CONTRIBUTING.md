# Contributing to json-schema-diff

Thank you for your interest in contributing to json-schema-diff! This document provides guidelines and information for contributors.

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** describing the issue
- **Detailed description** of the problem
- **Steps to reproduce** the bug
- **Expected vs actual behavior**
- **Environment details** (Ruby version, OS, gem version)
- **Sample files** if relevant (JSON schema, test files)

### Suggesting Features

Feature requests are welcome! Please:

- **Check existing issues** to avoid duplicates
- **Describe the use case** that motivates the feature
- **Provide examples** of how the feature would work
- **Consider implementation complexity** and maintenance burden

### Pull Requests

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following the coding standards
4. **Add tests** for new functionality
5. **Update documentation** if needed
6. **Ensure all tests pass** (`rake test`)
7. **Commit your changes** (`git commit -m 'Add amazing feature'`)
8. **Push to your branch** (`git push origin feature/amazing-feature`)
9. **Open a Pull Request**

## Development Setup

### Prerequisites

- Ruby 3.2.0 or higher
- Bundler

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/json-schema-diff.git
cd json-schema-diff

# Install dependencies
bundle install

# Run tests
rake test

# Run linting (if available)
rake lint
```

### Running Tests

```bash
# Run all tests
rake test

# Run specific test file
ruby test/json/schema/test_diff.rb

# Run specific test method
ruby test/json/schema/test_diff.rb -n test_comparer_detects_additions
```

## Coding Standards

### Ruby Style

- Follow standard Ruby conventions
- Use 2 spaces for indentation
- Keep line length under 120 characters
- Use descriptive variable and method names
- Add comments for complex logic

### Code Organization

- Keep classes focused and single-purpose
- Use modules for shared functionality
- Follow existing file structure and naming conventions
- Place new features in appropriate modules

### Testing

- Write tests for all new functionality
- Use descriptive test method names
- Test both success and error cases
- Include edge cases and boundary conditions
- Use helper methods to reduce test duplication

Example test structure:
```ruby
def test_descriptive_test_name
  # Arrange
  schema = create_test_schema
  
  # Act
  result = schema.parse_field("field.path")
  
  # Assert
  assert_equal expected_value, result
end
```

### Documentation

- Update README.md for new features
- Add inline documentation for public methods
- Include usage examples for new functionality
- Update CHANGELOG.md with notable changes

## Architecture Overview

### Core Components

- **SchemaParser**: Parses JSON Schema files and extracts field metadata
- **Comparer**: Performs recursive comparison of JSON objects using schema guidance
- **Formatter**: Formats diff results for human-readable or machine-readable output
- **CLI**: Command-line interface using Thor

### Key Design Principles

- **Schema-driven**: Use JSON Schema metadata to enhance diff output
- **Configurable**: Support various output formats and filtering options
- **Extensible**: Easy to add new output formats or schema features
- **Defensive**: Handle malformed inputs gracefully with clear error messages

## Testing Guidelines

### Test Categories

1. **Unit tests**: Test individual components in isolation
2. **Integration tests**: Test component interactions
3. **CLI tests**: Test command-line interface functionality
4. **Example tests**: Validate example files work correctly

### Test Data

- Use temporary files for test schemas and JSON files
- Include realistic examples that reflect real-world usage
- Test edge cases like empty objects, deeply nested structures
- Validate error handling with invalid inputs

### Performance Considerations

- Test with reasonably large JSON files
- Ensure tests complete in reasonable time
- Avoid tests that consume excessive memory

## Release Process

### Version Numbers

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

1. Update version in `lib/json/schema/diff/version.rb`
2. Update CHANGELOG.md with release notes
3. Ensure all tests pass
4. Tag the release (`git tag v1.2.3`)
5. Push tags (`git push --tags`)
6. Build and publish gem (`gem build && gem push`)

## Documentation

### README Updates

When adding features, update the README with:

- Installation instructions (if changed)
- Usage examples for new features
- Command-line options
- Configuration details

### Code Documentation

- Document public methods with YARD comments
- Include parameter types and return values
- Provide usage examples for complex methods
- Document error conditions and exceptions

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Email**: andrew@ecosyste.ms for security issues

## Recognition

Contributors will be recognized in:

- Release notes
- Contributors section (if we add one)
- Special thanks for significant contributions

Thank you for contributing to json-schema-diff!