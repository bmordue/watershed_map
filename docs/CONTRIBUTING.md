# Contributing to Watershed Mapping

Thank you for your interest in contributing to the Watershed Mapping project! This document provides guidelines and instructions for contributing.

## Table of Contents

* [Code of Conduct](#code-of-conduct)
* [Getting Started](#getting-started)
* [Development Setup](#development-setup)
* [How to Contribute](#how-to-contribute)
* [Code Style Guidelines](#code-style-guidelines)
* [Testing Requirements](#testing-requirements)
* [Pull Request Process](#pull-request-process)
* [Release Process](#release-process)
* [Getting Help](#getting-help)

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors:

* **Be respectful**: Treat others with respect and consideration
* **Be collaborative**: Work together and help each other
* **Be inclusive**: Welcome diverse perspectives and backgrounds
* **Be constructive**: Provide helpful feedback and suggestions
* **Be patient**: Remember that everyone is learning

## Getting Started

### Prerequisites

To contribute to this project, you should be familiar with:

* Basic GIS concepts (rasters, vectors, coordinate systems)
* Command-line interfaces (bash/shell scripting)
* Python programming
* Git and GitHub workflows

### Understanding the Project

Before contributing, take time to:

1. **Read the documentation**:
   - [README.md](../README.md) - Project overview
   - [watershed_mapping_guide.md](docs/watershed_mapping_guide.md) - Detailed workflow
   - [CONFIG_SYSTEM.md](docs/CONFIG_SYSTEM.md) - Configuration system
   - [ARCHITECTURE_ASSESSMENT.md](ARCHITECTURE_ASSESSMENT.md) - Architecture overview

2. **Review Architecture Decision Records**:
   - [docs/adr/](docs/adr/) - Key architectural decisions explained

3. **Explore the codebase**:
   - `scripts/` - Pipeline processing scripts
   - `lib/` - Shared library code
   - `config/` - Configuration files

## Development Setup

### Quick Start

1. **Install Nix** (recommended):
   ```bash
   curl -L https://nixos.org/nix/install | sh
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/bmordue/watershed_map.git
   cd watershed_map
   ```

3. **Enter development environment**:
   ```bash
   nix-shell
   ```

4. **Verify setup**:
   ```bash
   # Check that tools are available
   grass --version
   python3 -c "import geopandas; print('Ready!')"
   ```

### Alternative Setup (without Nix)

If you prefer not to use Nix, you can install dependencies manually:

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install -y grass-core gdal-bin gmt python3 python3-pip
pip3 install geopandas rasterio shapely fiona pyproj numpy pyyaml rasterstats
```

**macOS** (using Homebrew):
```bash
brew install grass gdal gmt python
pip3 install geopandas rasterio shapely fiona pyproj numpy pyyaml rasterstats
```

### Running the Pipeline

```bash
# Create GRASS location
./scripts/setup_environment.sh

# Download sample data (requires internet)
./scripts/acquire_data.sh

# Process DEM
./scripts/process_dem.sh

# Or run complete pipeline
./scripts/complete_pipeline.sh
```

## How to Contribute

### Reporting Bugs

Found a bug? Please help us fix it:

1. **Check existing issues**: Search to see if the bug is already reported
2. **Create a new issue**: Use the bug report template
3. **Provide details**:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs. actual behavior
   - Environment details (OS, GRASS version, etc.)
   - Error messages or logs
   - Sample data if possible

### Suggesting Enhancements

Have an idea for improvement?

1. **Check existing issues**: See if it's already suggested
2. **Create a feature request**: Use the feature request template
3. **Describe the enhancement**:
   - What problem does it solve?
   - How should it work?
   - What alternatives did you consider?
   - Any implementation ideas?

### Contributing Code

Ready to write code? Great!

1. **Find or create an issue**: Discuss the change before starting
2. **Fork the repository**: Create your own copy
3. **Create a branch**: Use a descriptive name
   ```bash
   git checkout -b feature/add-watershed-statistics
   git checkout -b fix/coordinate-validation
   git checkout -b docs/improve-readme
   ```
4. **Make your changes**: Follow the guidelines below
5. **Test your changes**: Ensure everything works
6. **Commit with clear messages**: See commit guidelines
7. **Push to your fork**: 
   ```bash
   git push origin feature/add-watershed-statistics
   ```
8. **Create a Pull Request**: Fill out the PR template

### Contributing Documentation

Documentation improvements are always welcome:

* Fix typos or unclear explanations
* Add examples or tutorials
* Improve API documentation
* Translate documentation (if multilingual support added)
* Create diagrams or visualizations

## Code Style Guidelines

### Python Code

Follow [PEP 8](https://pep8.org/) style guidelines:

* **Formatting**: Use 4 spaces for indentation (no tabs)
* **Line length**: Maximum 100 characters
* **Imports**: Group imports (standard library, third-party, local)
* **Naming**:
  - `snake_case` for functions and variables
  - `PascalCase` for classes
  - `UPPER_CASE` for constants

**Example**:
```python
"""Module for watershed processing."""

import os
from pathlib import Path

import geopandas as gpd
import rasterio

from lib.config import load_config


DEFAULT_THRESHOLD = 1000


class WatershedProcessor:
    """Process watershed data from DEM."""
    
    def __init__(self, config_path: str):
        self.config = load_config(config_path)
    
    def process(self, dem_path: str) -> gpd.GeoDataFrame:
        """Process DEM and return watershed boundaries."""
        # Implementation
        pass
```

**Recommended tools**:
* `black` - Code formatter
* `flake8` - Linter
* `mypy` - Type checker

### Shell Scripts

Follow shell scripting best practices:

* **Shebang**: Use `#!/bin/sh` for portability or `#!/bin/bash` if bash-specific
* **Set flags**: Use `set -e` (exit on error), `set -u` (error on undefined var)
* **Quoting**: Always quote variables: `"$variable"`
* **Functions**: Use functions for reusable code
* **Comments**: Explain complex logic

**Example**:
```bash
#!/bin/sh
# process_dem.sh - Process Digital Elevation Model

set -eu  # Exit on error, undefined variable

# Configuration
DEM_FILE="${1:-data/raw/dem.tif}"
OUTPUT_DIR="${2:-data/processed}"

# Validate inputs
validate_input() {
    if [ ! -f "$DEM_FILE" ]; then
        echo "Error: DEM file not found: $DEM_FILE" >&2
        return 1
    fi
}

# Main processing
main() {
    validate_input
    mkdir -p "$OUTPUT_DIR"
    
    echo "Processing DEM: $DEM_FILE"
    # Processing logic here
}

main "$@"
```

**Recommended tools**:
* `shellcheck` - Shell script linter

### Configuration Files

YAML configuration guidelines:

* **Indentation**: 2 spaces (no tabs)
* **Keys**: Use `snake_case`
* **Comments**: Explain non-obvious values
* **Organization**: Group related settings

**Example**:
```yaml
# Watershed processing configuration
processing:
  watersheds:
    # Minimum flow accumulation to define stream
    stream_threshold: 1000
    
    # Outlet points for watershed delineation
    outlets:
      - name: "dee"
        coordinates: [384500, 801500]
```

## Testing Requirements

### Running Tests

Currently, the project has limited automated tests. We're working on improving this:

```bash
# Validate configuration
python3 lib/config.py config/default.yaml

# Run pipeline on test data
CONFIG_FILE=config/environments/development.yaml ./scripts/complete_pipeline.sh
```

### Test Guidelines

When adding new features:

1. **Test manually**: Run affected scripts and verify outputs
2. **Test edge cases**: Invalid inputs, missing files, etc.
3. **Test on clean environment**: Use `nix-shell` for isolation
4. **Document test procedure**: In PR description

### Future Testing (Planned)

We plan to add:
* Unit tests for Python modules (pytest)
* Integration tests for pipeline stages
* Shell script tests (bats)
* Configuration validation tests

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Changes have been tested manually
- [ ] Documentation updated (if applicable)
- [ ] Configuration examples updated (if applicable)
- [ ] Commit messages are clear and descriptive

### PR Checklist

When creating a pull request:

1. **Use the PR template**: Fill out all sections
2. **Link related issues**: Reference issue numbers
3. **Describe changes**: What and why
4. **List testing done**: How you verified changes
5. **Add screenshots**: For visual changes (maps, outputs)
6. **Request review**: Tag relevant reviewers

### Review Process

1. **Automated checks**: CI/CD must pass
2. **Code review**: At least one approval required
3. **Discussion**: Address reviewer comments
4. **Updates**: Push additional commits if needed
5. **Approval**: Reviewer approves changes
6. **Merge**: Maintainer merges PR

### After Merge

* Delete your feature branch (optional)
* Close related issues (if not auto-closed)
* Update documentation (if needed)
* Announce in discussions (for major features)

## Commit Message Guidelines

Write clear, descriptive commit messages:

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

* `feat`: New feature
* `fix`: Bug fix
* `docs`: Documentation changes
* `style`: Code style changes (formatting, etc.)
* `refactor`: Code refactoring
* `test`: Adding or updating tests
* `chore`: Maintenance tasks

### Examples

```
feat(config): Add support for custom coordinate systems

Allow users to specify any EPSG code in configuration.
Previously limited to EPSG:27700 (British National Grid).

Closes #123
```

```
fix(process_dem): Validate outlet coordinates before processing

Prevent shell injection by validating coordinate values.
Add range checking based on project bounds.

Related to security audit findings.
```

```
docs(README): Add troubleshooting section

Add common issues and solutions based on user feedback.
Include debugging commands and tips.
```

## Release Process

(To be defined - project currently in active development)

## Getting Help

### Questions?

* **General questions**: Open a discussion on GitHub
* **Bug reports**: Create an issue
* **Security issues**: Email maintainers directly (do not open public issue)
* **Feature ideas**: Start a discussion or create a feature request

### Resources

* **Documentation**: [docs/](docs/) directory
* **ADRs**: [docs/adr/](docs/adr/) - Architecture decisions explained
* **Examples**: [watershed_mapping_guide.md](docs/watershed_mapping_guide.md)

### Community

* **GitHub Discussions**: Ask questions and share ideas
* **Issues**: Track bugs and features
* **Pull Requests**: Contribute code and documentation

## Recognition

Contributors will be recognized:

* In commit history (Git)
* In CONTRIBUTORS.md file (if we create one)
* In release notes (for significant contributions)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (to be determined - currently unlicensed).

---

Thank you for contributing to the Watershed Mapping project! Your help makes this project better for everyone.

**Questions?** Open an issue or start a discussion.

**Last Updated**: February 2026
