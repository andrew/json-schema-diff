# Capslock Examples

This directory contains examples for [Capslock](https://github.com/google/capslock), Google's Go capability analysis tool.

## Files

- `capslock.schema.json` - Official Capslock JSON output schema
- `capslock-v0.5.0.json` - Sample capability report from capslock v0.5.0
- `capslock-v0.6.0.json` - Sample capability report from capslock v0.6.0

## Example Usage

```bash
# Compare capability analysis between versions
json-schema-diff capslock.schema.json capslock-v0.5.0.json capslock-v0.6.0.json

# Real-world usage with actual capslock output
capslock -output json > current-capabilities.json
json-schema-diff capslock.schema.json previous-capabilities.json current-capabilities.json
```

## Key Changes Demonstrated

- **New dangerous capability**: v0.6.0 introduces `CAPABILITY_ARBITRARY_EXECUTION` via transitive dependency
- **Dependency tracking**: New suspicious library `github.com/suspicious/lib@v1.2.3` added
- **Call path analysis**: Detailed function call chains showing how capabilities are reached
- **Module version updates**: Tracking dependency version changes across releases