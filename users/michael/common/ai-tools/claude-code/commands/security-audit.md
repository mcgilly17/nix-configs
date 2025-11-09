---
allowed-tools: Read, Grep, Bash
argument-hint: "[scope]"
description: Security analysis using security-auditor agent
---

# Security Audit Command

Invokes the security-auditor agent for comprehensive security analysis.

## Usage

```bash
/security-audit                    # Audit entire project
/security-audit src/auth          # Audit specific directory
/security-audit --owasp           # OWASP Top 10 focus
/security-audit --dependencies    # Dependency CVE scan
```

## Process

1. **Determine scope** - What to audit? (full project, specific area)
2. **Scan codebase** - Look for security patterns
3. **Invoke security-auditor agent** with findings
4. **Present report** with prioritized issues

## What Gets Audited

### OWASP Top 10
- Broken Access Control
- Cryptographic Failures
- Injection vulnerabilities
- Insecure Design
- Security Misconfiguration
- Vulnerable Components
- Authentication Failures
- Data Integrity issues
- Logging & Monitoring gaps
- SSRF vulnerabilities

### Code-Level Security
- Input validation
- Authentication/Authorization
- Data protection
- Output encoding

### Infrastructure
- Docker/container security
- Kubernetes policies
- Network configuration

### Dependencies
- CVE scanning
- License compliance
- Outdated packages

## Report Format

- 🔴 **Critical Issues**: Fix immediately
- 🟡 **High Priority**: Fix soon
- 🟢 **Recommendations**: Best practices
- ✅ **Good Practices**: Security done well

Each issue includes:
- Vulnerability description
- Impact assessment
- Specific fix steps
- Verification method
