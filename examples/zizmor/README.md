# Zizmor Examples

This directory contains examples for [Zizmor](https://github.com/zizmorcore/zizmor), a GitHub Actions security auditor.

## Files

- `zizmor.schema.json` - Official zizmor JSON output schema (v1)
- `zizmor-v0.1.0.json` - Sample audit report from zizmor v0.1.0
- `zizmor-v0.2.0.json` - Sample audit report from zizmor v0.2.0

## Example Usage

```bash
# Compare audit results between versions
json-schema-diff zizmor.schema.json zizmor-v0.1.0.json zizmor-v0.2.0.json

# Real-world usage with actual zizmor output
zizmor --format json --output current-audit.json .
json-schema-diff zizmor.schema.json previous-audit.json current-audit.json
```

## Key Changes Demonstrated

- **New security findings**: v0.2.0 introduces detection of hardcoded credentials
- **Severity escalation**: Dangerous actions finding upgraded from Medium to High severity
- **Rich location data**: File paths, line numbers, and byte offsets for precise issue location