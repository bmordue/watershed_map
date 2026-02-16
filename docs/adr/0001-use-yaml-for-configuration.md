# ADR-0001: Use YAML for Configuration Management

**Status**: Accepted  
**Date**: 2024-01-15  
**Deciders**: Development Team  
**Technical Story**: Feature proposal for data/logic separation

---

## Context and Problem Statement

The watershed mapping project initially had configuration parameters hard-coded throughout shell scripts and Python code. This created several problems:

* Difficult to adapt the system for different regions without modifying code
* Parameter changes required editing multiple files
* Risk of inconsistencies when updating processing parameters
* Challenging to track what configuration was used for specific runs
* Limited ability to support different environments (dev, test, production)

We need a configuration management system that:
* Externalizes all configuration parameters
* Supports hierarchical configuration
* Allows environment-specific overrides
* Is human-readable and easy to edit
* Integrates well with both Python and shell scripts

## Decision Drivers

* **Reusability**: Enable easy adaptation to different watersheds and regions
* **Maintainability**: Centralize parameter management to reduce maintenance burden
* **Testability**: Support separate test configurations
* **Collaboration**: Allow user-specific settings without code changes
* **Documentation**: Configuration files serve as explicit parameter documentation
* **Tooling**: Good ecosystem support in both Python and shell

## Considered Options

1. **YAML Configuration Files**
2. **JSON Configuration Files**
3. **INI/TOML Configuration Files**
4. **Environment Variables Only**
5. **Python Configuration Files**

## Decision Outcome

**Chosen option**: "YAML Configuration Files", because it provides the best balance of human readability, hierarchical structure support, and excellent tooling in both Python and shell environments.

### Positive Consequences

* Human-readable format easy for non-programmers to edit
* Native support for nested/hierarchical structures
* Excellent library support (PyYAML in Python, yq for shell)
* Can embed comments for documentation
* Standard format widely used in DevOps and configuration management
* Supports data type detection (strings, numbers, booleans, lists, etc.)
* Easy to version control and diff

### Negative Consequences

* Slightly more complex to parse than INI files
* YAML specification can be tricky (indentation sensitivity)
* Requires PyYAML dependency
* Shell scripts need helper functions or yq for parsing

## Pros and Cons of the Options

### Option 1: YAML Configuration Files

Standard structured configuration format with excellent ecosystem support.

**Pros:**
* Highly human-readable with clear hierarchical structure
* Native support for complex data structures (nested objects, arrays)
* Strong library support in Python (PyYAML) and command-line tools (yq)
* Can include comments for documentation
* Industry standard for configuration (Kubernetes, Ansible, CI/CD)
* Supports multiple documents in one file

**Cons:**
* Indentation-sensitive (can cause errors if not careful)
* More complex specification than simpler formats
* Requires external dependency (PyYAML)
* Can be parsed differently by different parsers (minor edge cases)

### Option 2: JSON Configuration Files

Ubiquitous data format with native support in most languages.

**Pros:**
* Native support in Python (json module) and JavaScript
* Strict specification - unambiguous parsing
* Fast parsing performance
* No additional dependencies needed

**Cons:**
* **No comment support** - major limitation for documentation
* Less human-readable with quotes and strict syntax
* No support for multi-line strings
* No variable references or anchors
* Trailing commas not allowed (common error source)

### Option 3: INI/TOML Configuration Files

Simple key-value or section-based configuration formats.

**Pros:**
* Very simple and easy to understand
* No indentation sensitivity (INI)
* TOML is more structured and supports data types
* Minimal parsing overhead

**Cons:**
* Limited hierarchical structure support (especially INI)
* Not well-suited for complex nested configurations
* Less common in modern Python projects
* Would require flattening our hierarchical configuration structure

### Option 4: Environment Variables Only

Use environment variables for all configuration.

**Pros:**
* No file parsing needed
* Standard practice in 12-factor apps
* Easy to override in different environments
* Secure for secrets (not stored in files)

**Cons:**
* **Poor support for hierarchical data** - major limitation
* Difficult to manage many configuration parameters
* No good way to handle lists or nested objects
* Not easily version controlled
* Requires extensive variable naming conventions
* Configuration becomes scattered across environment

### Option 5: Python Configuration Files

Use Python modules (.py files) for configuration.

**Pros:**
* Full Python expressiveness (conditionals, imports, etc.)
* No parsing overhead in Python code
* Can compute values dynamically
* Type checking possible

**Cons:**
* **Not accessible from shell scripts** - major limitation
* Security risk (code execution)
* Less portable across languages
* Not as human-friendly for non-programmers
* Harder to validate statically
* Merge conflicts more complex

## Links and References

* [PyYAML Documentation](https://pyyaml.org/)
* [YAML Specification](https://yaml.org/spec/)
* [yq - Command-line YAML processor](https://github.com/mikefarah/yq)
* [Feature Proposal: Separate Data from Logic](../FEATURE_PROPOSAL_DATA_LOGIC_SEPARATION.md)
* [Configuration System Documentation](../CONFIG_SYSTEM.md)

## Implementation Notes

### Configuration Structure

```yaml
project:
  name: "Aberdeenshire Watershed Mapping"
  coordinate_system: "EPSG:27700"
  region:
    bounds: [350000, 450000, 780000, 880000]
    name: "Aberdeenshire"

data_sources:
  dem:
    source: "Copernicus GLO-30"
    resolution: 30
    filename: "copdem_glo30_aberdeenshire.tif"

processing:
  watersheds:
    stream_threshold: 1000
    outlets:
      - name: "dee"
        coordinates: [384500, 801500]

paths:
  data_dir: "data"
  raw_data: "${data_dir}/raw"
  processed_data: "${data_dir}/processed"
```

### Python Integration

Created `lib/config.py` with ConfigLoader class:
* `load_config()` - Load configuration from YAML file
* `get_config(key_path, default)` - Get value using dot notation
* Path variable expansion for `${variable}` references
* Validation of required sections

### Shell Integration

Created `lib/config_loader.sh` with bash functions:
* `load_config()` - Parse YAML and export as environment variables
* `get_config_value(key)` - Get specific value from config
* `validate_config()` - Verify required sections exist

## Validation and Acceptance Criteria

* ✅ Configuration successfully loaded in both Python and shell scripts
* ✅ All hard-coded parameters externalized to YAML files
* ✅ Environment-specific configurations working (development.yaml)
* ✅ Backward compatibility maintained (fallback values)
* ✅ Documentation updated with configuration examples

## Review Date

To be reviewed: January 2025 (after 1 year of use)

---

**Related ADRs**:
* ADR-0003: Nix for Environment Management
