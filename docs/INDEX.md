# Documentation Index

Welcome to the Watershed Mapping project documentation! This index helps you find the right documentation for your needs.

## 📚 Documentation Structure

```
watershed_map/
├── README.md                          # Project overview and quick start
├── CONTRIBUTING.md                    # How to contribute
├── SECURITY.md                        # Security policy
├── TROUBLESHOOTING.md                 # Common issues and solutions
├── ARCHITECTURE_ASSESSMENT.md         # Architecture review and roadmap
└── docs/
    ├── CONFIG_SYSTEM.md               # Configuration system reference
    ├── FEATURE_PROPOSAL_DATA_LOGIC_SEPARATION.md  # Design proposal
    ├── watershed_mapping_guide.md     # Detailed workflow guide
    └── adr/                           # Architecture Decision Records
        ├── README.md                  # ADR introduction and index
        ├── template.md                # ADR template
        ├── 0001-use-yaml-for-configuration.md
        ├── 0002-choose-grass-gis-for-watershed-analysis.md
        └── 0003-use-nix-for-environment-management.md
```

## 🚀 Getting Started

**New to the project?** Start here:

1. **[README.md](../README.md)** - Overview, quick start, technology stack
2. **[Watershed Mapping Guide](watershed_mapping_guide.md)** - Detailed workflow explanation
3. **[Configuration System](CONFIG_SYSTEM.md)** - How to configure for your region
4. **[Troubleshooting Guide](../TROUBLESHOOTING.md)** - Common issues and fixes

## 👩‍💻 For Contributors

**Want to contribute?** Read these:

1. **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Development setup, code style, PR process
2. **[Architecture Assessment](../ARCHITECTURE_ASSESSMENT.md)** - Current state and improvement opportunities
3. **[Architecture Decision Records](adr/)** - Understanding key design decisions
4. **[Security Policy](../SECURITY.md)** - Security best practices and reporting

## 🏗️ Architecture Documentation

**Understanding the system design:**

### Architecture Assessment
* **[ARCHITECTURE_ASSESSMENT.md](../ARCHITECTURE_ASSESSMENT.md)** (31,623 lines)
  - Comprehensive review of all architectural aspects
  - Prioritized improvement recommendations
  - Implementation roadmap with timelines
  - Success metrics and risk assessment

### Architecture Decision Records (ADRs)
* **[ADR Index](adr/README.md)** - Overview and how to use ADRs
* **[ADR-0001](adr/0001-use-yaml-for-configuration.md)** - Why YAML for configuration
* **[ADR-0002](adr/0002-choose-grass-gis-for-watershed-analysis.md)** - Why GRASS GIS
* **[ADR-0003](adr/0003-use-nix-for-environment-management.md)** - Why Nix

### Design Proposals
* **[Feature Proposal: Data/Logic Separation](FEATURE_PROPOSAL_DATA_LOGIC_SEPARATION.md)**
  - Rationale for separating configuration from code
  - Technical implementation approach
  - Migration strategy

## 📖 User Guides

### Complete Workflow Guide
* **[Watershed Mapping Guide](watershed_mapping_guide.md)** (12,368 lines)
  - Complete CLI workflow
  - Data sources and acquisition
  - DEM processing with GRASS GIS
  - Watershed analysis
  - Map creation with GMT
  - Step-by-step examples

### Configuration Reference
* **[Configuration System](CONFIG_SYSTEM.md)** (5,021 lines)
  - Configuration file structure
  - Environment-specific configurations
  - Using configuration in scripts
  - Migration from hard-coded values
  - Examples for custom regions

## 🔧 Maintenance & Operations

### Troubleshooting
* **[TROUBLESHOOTING.md](../TROUBLESHOOTING.md)** (12,619 lines)
  - Quick diagnostics
  - Installation issues
  - GRASS GIS problems
  - Data processing issues
  - Performance optimization
  - CI/CD debugging

### Security
* **[SECURITY.md](../SECURITY.md)** (7,907 lines)
  - Security policy
  - Reporting vulnerabilities
  - Known security considerations
  - Security best practices
  - Improvement roadmap

### Contributing
* **[CONTRIBUTING.md](../CONTRIBUTING.md)** (11,370 lines)
  - Development setup
  - Code style guidelines
  - Testing requirements
  - Pull request process
  - Commit message format

## 📊 Quick Reference Tables

### By User Type

| User Type | Recommended Reading | Order |
|-----------|-------------------|-------|
| **New User** | README → Watershed Guide → Config System | 1-2-3 |
| **Developer** | CONTRIBUTING → Architecture Assessment → ADRs | 1-2-3 |
| **Researcher** | Watershed Guide → Feature Proposal → ADRs | 1-2-3 |
| **DevOps** | README → TROUBLESHOOTING → SECURITY | 1-2-3 |
| **Architect** | Architecture Assessment → ADRs → Feature Proposal | 1-2-3 |

### By Topic

| Topic | Documents | Total Lines |
|-------|-----------|-------------|
| **Architecture** | ARCHITECTURE_ASSESSMENT.md, ADRs | ~55,000 |
| **User Guides** | watershed_mapping_guide.md, CONFIG_SYSTEM.md | ~17,000 |
| **Operations** | TROUBLESHOOTING.md, SECURITY.md | ~20,000 |
| **Development** | CONTRIBUTING.md, Feature Proposal | ~28,000 |
| **Overview** | README.md | ~190 |

### By Document Purpose

| Purpose | Documents |
|---------|-----------|
| **Reference** | CONFIG_SYSTEM.md, ARCHITECTURE_ASSESSMENT.md |
| **Tutorial** | watershed_mapping_guide.md, CONTRIBUTING.md |
| **Explanation** | ADRs, FEATURE_PROPOSAL.md |
| **How-to** | TROUBLESHOOTING.md, README.md |

## 🔗 Common Use Cases

### "I want to run watershed analysis for my region"
1. Read [README Quick Start](../README.md#quick-start)
2. Review [Configuration System](CONFIG_SYSTEM.md)
3. Copy and customize `config/default.yaml`
4. Follow [Watershed Mapping Guide](watershed_mapping_guide.md)
5. Check [Troubleshooting](../TROUBLESHOOTING.md) if issues arise

### "I want to understand why decisions were made"
1. Read [Architecture Assessment](../ARCHITECTURE_ASSESSMENT.md)
2. Review [Architecture Decision Records](adr/)
3. Read [Feature Proposal](FEATURE_PROPOSAL_DATA_LOGIC_SEPARATION.md)

### "I want to contribute code"
1. Read [CONTRIBUTING.md](../CONTRIBUTING.md)
2. Review [Architecture Assessment](../ARCHITECTURE_ASSESSMENT.md) for improvement areas
3. Check [ADRs](adr/) for design constraints
4. Follow contribution workflow

### "I have a problem/error"
1. Check [Troubleshooting Guide](../TROUBLESHOOTING.md)
2. Search [GitHub Issues](https://github.com/bmordue/watershed_map/issues)
3. Run diagnostic commands from troubleshooting guide
4. Create new issue with diagnostic information

### "I found a security issue"
1. Read [Security Policy](../SECURITY.md)
2. Email maintainers (do not open public issue)
3. Follow responsible disclosure process

## 📈 Documentation Statistics

* **Total Markdown Files**: 13
* **Total Lines of Documentation**: ~4,881
* **Architecture Decision Records**: 3 active + 1 template
* **User Guides**: 3
* **Operational Guides**: 3
* **Development Guides**: 2
* **Overview/Index Files**: 2

## 🎯 Documentation Goals

This documentation aims to:

* ✅ **Enable self-service**: Users can solve problems without asking
* ✅ **Explain decisions**: Clear rationale for architectural choices
* ✅ **Facilitate onboarding**: New contributors can get started quickly
* ✅ **Ensure reproducibility**: Complete instructions for setup and use
* ✅ **Support multiple audiences**: Different paths for different user types

## 🔄 Keeping Documentation Updated

Documentation is maintained alongside code:

* **README.md**: Updated with new features and requirements
* **ADRs**: Created for significant architectural decisions
* **Guides**: Updated when workflows change
* **TROUBLESHOOTING**: Expanded based on user issues
* **ARCHITECTURE_ASSESSMENT**: Reviewed quarterly

## 📝 Contributing to Documentation

Documentation improvements are always welcome:

* Fix typos or unclear sections
* Add examples or tutorials
* Improve diagrams
* Translate documentation
* Create video tutorials

See [CONTRIBUTING.md](../CONTRIBUTING.md#contributing-documentation) for guidelines.

## 🆘 Getting Help

Can't find what you're looking for?

* **Search**: Use GitHub's search across all documentation
* **Issues**: Check existing issues and discussions
* **Ask**: Create a new discussion or issue
* **Community**: Reach out via project channels

## 📅 Maintenance Schedule

* **Weekly**: Fix typos and minor issues
* **Monthly**: Review for accuracy and completeness  
* **Quarterly**: Major updates based on feedback
* **Annually**: Comprehensive review and reorganization

---

**Last Updated**: February 2026  
**Maintained by**: Development Team  
**Feedback Welcome**: Open an issue or discussion!

**Total Documentation**: ~120KB of markdown across 13 files
