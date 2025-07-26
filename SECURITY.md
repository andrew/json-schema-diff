# Security Policy

## Supported Versions

We actively support and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The json-schema-diff team takes security seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Create a Public Issue

Please do not report security vulnerabilities through public GitHub issues, discussions, or pull requests.

### 2. Report Privately

Send a detailed report to **andrew@ecosyste.ms** with:

- **Subject**: `[SECURITY] json-schema-diff - [Brief Description]`
- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** assessment
- **Suggested fix** (if you have one)
- **Your contact information** for follow-up

### 3. What to Include

Please provide as much information as possible:

```
- Affected versions
- Attack vectors
- Proof of concept (if safe to share)
- Environmental details (Ruby version, OS, etc.)
- Any relevant configuration details
```

## Response Process

### Initial Response

- **24-48 hours**: We will acknowledge receipt of your report
- **Initial assessment**: Within 1 week of acknowledgment
- **Status updates**: Weekly until resolution

### Investigation

We will:
1. **Confirm** the vulnerability exists
2. **Assess** the severity and impact
3. **Develop** a fix and mitigation strategy
4. **Test** the fix thoroughly
5. **Coordinate** disclosure timeline

### Resolution

- **High/Critical**: Immediate fix and release
- **Medium**: Fix within 30 days
- **Low**: Fix in next regular release cycle

## Security Considerations

### Input Validation

The json-schema-diff library processes JSON files and JSON Schema documents:

- **JSON parsing**: Validates JSON syntax and structure
- **Schema validation**: Ensures schema conforms to JSON Schema specification
- **Path traversal**: Validates file paths to prevent directory traversal attacks
- **Memory usage**: Guards against extremely large JSON files that could cause DoS

### Potential Risk Areas

Areas that warrant security attention:

1. **JSON parsing**: Malformed JSON could cause parsing errors or crashes
2. **Schema complexity**: Deeply nested schemas could cause stack overflow
3. **File operations**: Reading files requires proper path validation
4. **Regular expressions**: Pattern matching should be safe from ReDoS attacks

### Safe Usage Practices

When using json-schema-diff in applications:

- **Validate input**: Don't trust user-provided file paths or JSON content
- **Handle errors**: Properly catch and handle parsing exceptions
- **Limit resources**: Implement timeouts and memory limits for large files
- **Sanitize output**: Be careful when displaying diff results in web applications

## Disclosure Policy

### Coordinated Disclosure

We follow coordinated disclosure principles:

1. **Private reporting** allows us to fix issues before public disclosure
2. **Reasonable timeline** for fixes (typically 90 days maximum)
3. **Credit and recognition** for responsible reporters
4. **Public disclosure** after fixes are available

### Public Disclosure

After a fix is released:

1. **Security advisory** published on GitHub
2. **CVE requested** if applicable
3. **Release notes** include security information
4. **Community notification** through appropriate channels

## Security Updates

### Notification Channels

Security updates are announced through:

- **GitHub Security Advisories**
- **RubyGems security alerts**
- **Release notes and CHANGELOG**
- **Project README updates**

### Update Recommendations

To stay secure:

- **Monitor** our security advisories
- **Update regularly** to the latest version
- **Review** release notes for security fixes
- **Subscribe** to GitHub notifications for this repository

## Contact Information

**Security Contact**: andrew@ecosyste.ms

**Response Time**: We aim to acknowledge security reports within 24-48 hours

---

Thank you for helping keep json-schema-diff and its users safe!