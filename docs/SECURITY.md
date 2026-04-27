# Security Policy

## Supported Versions

This project is currently in active development. Security updates are provided for the latest version on the `main` branch.

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| < 1.0   | :x:                |

## Security Considerations

### Data Processing

This project processes geospatial data through several stages:

* **DEM Processing**: Digital Elevation Models can be large files (GBs). Ensure adequate disk space and memory.
* **External Data Sources**: Data is downloaded from external sources. Verify URLs before processing.
* **Coordinate Inputs**: User-provided coordinates are processed by GRASS GIS and shell scripts.

### Known Security Constraints

#### Input Validation (HIGH PRIORITY - Being Addressed)

Current limitations being addressed:
* ⚠️ User-provided coordinates in configuration files are not fully validated
* ⚠️ Some shell scripts use `os.system()` which can be vulnerable to injection
* ⚠️ Data source URLs in configuration not validated before download

**Mitigation**: These issues are documented in [ARCHITECTURE_ASSESSMENT.md](ARCHITECTURE_ASSESSMENT.md) and will be addressed in upcoming releases.

#### Dependencies

* **Nix Package Manager**: Provides reproducible builds with specific versions
* **Python Packages**: Managed via Nix and pip (rasterstats)
* **System Tools**: GRASS GIS, GDAL, GMT - all from trusted Nix repositories

### Security Best Practices

When using this project:

1. **Review configuration files**: Verify all URLs and paths before processing
2. **Validate data sources**: Only download data from trusted sources
3. **Check disk space**: Ensure adequate space before processing large datasets
4. **Use latest version**: Keep your installation up to date
5. **Isolate environment**: Use Nix shell for dependency isolation

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please help us responsibly disclose it.

### Please DO:

* **Email maintainers directly**: Send details to [maintainer email - to be added]
* **Provide details**: Include steps to reproduce, impact assessment, and any proposed fixes
* **Allow time for fix**: Give us reasonable time to address the issue before public disclosure
* **Follow coordinated disclosure**: We'll work with you on disclosure timing

### Please DON'T:

* **Open public issues**: Don't report security vulnerabilities in public issues
* **Publish exploits**: Don't publish exploit code before a fix is available
* **Attempt unauthorized access**: Don't test on systems you don't own

### What to Include

When reporting a vulnerability, please include:

* **Description**: Clear explanation of the vulnerability
* **Impact**: What could an attacker accomplish?
* **Reproduction steps**: How to trigger the vulnerability
* **Affected versions**: Which versions are impacted
* **Proposed fix**: If you have suggestions (optional)
* **Your contact info**: How we can reach you

### Response Process

1. **Acknowledgment**: We'll confirm receipt within 48 hours
2. **Assessment**: We'll evaluate severity and impact
3. **Fix development**: We'll work on a fix (timeframe depends on severity)
4. **Testing**: We'll test the fix thoroughly
5. **Release**: We'll release the fix and notify you
6. **Disclosure**: We'll coordinate public disclosure with you
7. **Recognition**: We'll credit you (if you wish) in release notes

### Severity Levels

We use the following severity classification:

* **Critical**: Remote code execution, data breach, privilege escalation
  - Response: Immediate (within 24-48 hours)
* **High**: Input validation bypass, denial of service
  - Response: Within 1 week
* **Medium**: Information disclosure, minor injection vulnerabilities
  - Response: Within 2-4 weeks
* **Low**: Minor issues with limited impact
  - Response: Next regular release

## Security Updates

Security updates will be:

* Released as soon as possible after a fix is ready
* Announced in GitHub releases
* Documented in CHANGELOG.md
* Mentioned in security advisories (for critical issues)

## Security Enhancements Roadmap

Planned security improvements (see [ARCHITECTURE_ASSESSMENT.md](ARCHITECTURE_ASSESSMENT.md)):

### Phase 1 (High Priority - Next 1-2 weeks)

- [ ] **HP-3.1**: Replace `os.system()` with safe `subprocess.run()` calls
- [ ] **HP-3.2**: Add input validation for coordinates and parameters
- [ ] **HP-3.3**: Enable HTTPS certificate verification for downloads

### Phase 2 (Medium Priority - Next 1-2 months)

- [ ] **MP-3.1**: Implement secrets management for API keys
- [ ] **MP-3.2**: Add dependency vulnerability scanning (Dependabot)
- [ ] **MP-3.3**: Restrict CI/CD permissions to minimum required

### Phase 3 (Low Priority - Future)

- [ ] **LP-3.1**: Add SECURITY.md to repository ✅ (Done)
- [ ] **LP-3.2**: Implement code signing for releases
- [ ] Add automated security testing in CI/CD

## Secure Development Practices

Contributors should follow these practices:

### Input Validation

```python
# Good: Validate inputs
def validate_coordinate(coord: float, min_val: float, max_val: float) -> bool:
    if not isinstance(coord, (int, float)):
        raise ValueError(f"Coordinate must be numeric")
    if coord < min_val or coord > max_val:
        raise ValueError(f"Coordinate outside valid range")
    return True

# Use validated inputs
validate_coordinate(x, 350000, 450000)
validate_coordinate(y, 780000, 880000)
```

### Safe Command Execution

```python
# Bad: Shell injection risk
os.system(f'command {user_input}')

# Good: Safe subprocess call
subprocess.run(['command', user_input], check=True, capture_output=True)
```

### Secure Downloads

```bash
# Good: Verify HTTPS and certificates
wget --secure-protocol=TLSv1_2 \
     --https-only \
     --ca-certificate=/etc/ssl/certs/ca-certificates.crt \
     "$URL" -O "$OUTPUT"
```

### Configuration Security

* Don't commit secrets or API keys
* Use environment variables for sensitive data
* Validate configuration files before use
* Sanitize user-provided paths and URLs

## Dependencies and Supply Chain

### Dependency Management

* **Nix packages**: Pinned versions in `shell.nix`
* **Python packages**: Requirements in Nix buildInputs
* **Review updates**: Check changelogs before updating

### Supply Chain Security

* All dependencies from trusted sources (nixpkgs, PyPI)
* Nix provides cryptographic verification of packages
* Regular dependency updates to patch vulnerabilities

### Vulnerability Scanning

We plan to implement:
* Automated dependency vulnerability scanning
* Regular security audits of dependencies
* Prompt updates for security patches

## Compliance and Standards

This project follows:

* **OWASP Top 10**: Web application security risks (where applicable)
* **CWE**: Common Weakness Enumeration for code quality
* **Secure coding practices**: Input validation, least privilege, defense in depth

## Contact

For security concerns:

* **Security vulnerabilities**: [Email to be added]
* **General security questions**: Open a GitHub discussion
* **Public security improvements**: Submit a pull request

## Acknowledgments

We appreciate responsible disclosure from security researchers. Contributors who report valid security issues will be:

* Thanked in release notes (with permission)
* Listed in security acknowledgments
* Credited in relevant CVE entries (if applicable)

## Additional Resources

* [ARCHITECTURE_ASSESSMENT.md](ARCHITECTURE_ASSESSMENT.md) - Security improvement roadmap
* [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
* [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
* [CWE Top 25](https://cwe.mitre.org/top25/)

---

**Last Updated**: February 2026  
**Next Review**: May 2026

Thank you for helping keep Watershed Mapping secure!
