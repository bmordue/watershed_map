# ADR-0003: Use Nix for Environment Management

**Status**: Accepted  
**Date**: 2024-01-12  
**Deciders**: Development Team  
**Technical Story**: Reproducible development and CI/CD environments

---

## Context and Problem Statement

The watershed mapping project requires a complex software stack including:

* GRASS GIS
* GDAL/OGR
* GMT (Generic Mapping Tools)
* Python with multiple geospatial packages (GeoPandas, Rasterio, Shapely, etc.)
* System libraries and dependencies

We face several challenges:
* Different versions of tools across development machines
* Difficult CI/CD environment setup
* Platform-specific installation issues
* Dependency conflicts between packages
* Non-reproducible builds and analysis results

We need an environment management solution that:
* Ensures reproducibility across all environments
* Simplifies installation and setup
* Handles complex dependencies automatically
* Works for both development and CI/CD
* Is itself open source

## Decision Drivers

* **Reproducibility**: Exact same versions across all environments
* **Ease of setup**: Simple onboarding for new developers
* **CI/CD integration**: Automated setup in GitHub Actions
* **Dependency management**: Complex GIS tool dependencies
* **Cross-platform**: Support Linux and macOS (primary platforms)
* **Declarative**: Configuration as code
* **Open source**: Aligned with project values

## Considered Options

1. **Nix Package Manager**
2. **Docker Containers**
3. **Conda/Mamba**
4. **Python Virtual Environment + System Packages**
5. **Ansible for Provisioning**

## Decision Outcome

**Chosen option**: "Nix Package Manager", because it provides the most comprehensive solution for reproducible environments, handles both system and language-specific packages, and integrates excellently with CI/CD while maintaining simplicity for developers.

### Positive Consequences

* **Perfect reproducibility**: Deterministic builds and environments
* **Easy setup**: Single `nix-shell` command enters complete environment
* **CI/CD friendly**: Works great with GitHub Actions via cachix
* **Isolation**: No conflicts with system packages
* **Declarative**: `shell.nix` describes entire environment
* **Rollback capability**: Can switch between environment versions
* **Cache friendly**: Binary cache reduces build times
* **Multi-language**: Handles Python, shell tools, system libraries in one place

### Negative Consequences

* **Learning curve**: Nix has unique concepts and syntax
* **Disk usage**: Can consume significant space with multiple versions
* **macOS limitations**: Some packages not available or require additional setup
* **Less common**: Smaller community than Docker/Conda
* **Build times**: Initial setup can be slow without cache

## Pros and Cons of the Options

### Option 1: Nix Package Manager

Purely functional package manager with strong reproducibility guarantees.

**Pros:**
* **Reproducibility**: Exact same environment every time
* **Atomic upgrades**: All-or-nothing environment changes
* **Rollback**: Easy to revert to previous environment
* **Multiple versions**: Different projects can use different versions without conflict
* **Source and binary packages**: Fast binary cache, build from source as fallback
* **Declarative**: `shell.nix` is clear specification
* **CI/CD integration**: Excellent GitHub Actions support via cachix
* **No contamination**: Isolated from system packages
* **Garbage collection**: Automatic cleanup of unused packages

**Cons:**
* **Learning curve**: Nix expression language is unique
* **Disk usage**: Store multiple versions of packages
* **Build times**: Initial builds can be slow (mitigated by binary cache)
* **Documentation**: Can be scattered for advanced topics
* **macOS support**: Some packages Linux-only

### Option 2: Docker Containers

Industry-standard containerization platform.

**Pros:**
* **Industry standard**: Widely known and used
* **Complete isolation**: Entire OS environment
* **Reproducible**: Dockerfile specifies exact setup
* **Cross-platform**: Works on Linux, macOS, Windows
* **Large ecosystem**: Many pre-built images available
* **Good CI/CD support**: All CI systems support Docker

**Cons:**
* **Heavier**: Full OS overhead vs. package manager
* **Development workflow**: Less seamless for interactive development
* **File permissions**: UID/GID mapping issues on Linux
* **Build times**: Dockerfile builds can be slow
* **Storage**: Images consume significant disk space
* **Not native**: Some performance overhead
* **Volume mounts**: Complexity for local development
* **GUI tools**: QGIS requires X11 forwarding or VNC

### Option 3: Conda/Mamba

Popular Python-centric package and environment manager.

**Pros:**
* **Python-friendly**: Designed for Python workflows
* **Large package repository**: conda-forge has many geospatial packages
* **Cross-platform**: Linux, macOS, Windows
* **Fast (Mamba)**: Mamba solver much faster than Conda
* **Popular in science**: Widely used in geospatial and data science
* **Simple to use**: Easy to understand concepts

**Cons:**
* **Incomplete solution**: Still need system packages for GRASS, GMT
* **Slower than Nix**: Even Mamba slower for large environments
* **Dependency conflicts**: Can still occur in complex environments
* **Reproducibility issues**: environment.yml not as strict as Nix
* **Disk usage**: Separate environments duplicate packages
* **No system libraries**: Can't install system-level dependencies
* **Binary compatibility**: Sometimes conflicts with system libraries

### Option 4: Python Virtual Environment + System Packages

Traditional approach with venv and system package manager.

**Pros:**
* **Simple**: Familiar to Python developers
* **Lightweight**: Minimal overhead
* **Standard**: Built into Python
* **Fast**: No additional downloads for system packages

**Cons:**
* **Not reproducible**: System packages vary by platform/distribution
* **Manual setup**: Must document all system dependencies
* **Fragile**: Easy to have version mismatches
* **Platform-specific**: Different instructions for Ubuntu, Fedora, macOS, etc.
* **Dependency hell**: System package conflicts
* **CI/CD complexity**: Must install many system packages in workflow
* **No rollback**: Can't easily revert changes

### Option 5: Ansible for Provisioning

Configuration management tool for automated setup.

**Pros:**
* **Idempotent**: Can run multiple times safely
* **Well-documented**: Good practices established
* **Flexible**: Can provision any configuration
* **Cross-platform**: Supports many operating systems

**Cons:**
* **Not environment isolation**: Modifies system globally
* **Slow**: Must install on each machine
* **Complexity**: Overkill for development environments
* **CI/CD overhead**: Ansible itself must be installed
* **Not declarative enough**: More imperative than Nix
* **No rollback**: Cannot revert changes easily

## Links and References

* [Nix Package Manager](https://nixos.org/)
* [Nix Pills Tutorial](https://nixos.org/guides/nix-pills/)
* [nix-shell Documentation](https://nixos.org/manual/nix/stable/command-ref/nix-shell.html)
* [Cachix - Nix binary cache](https://cachix.org/)
* [GitHub Action: install-nix-action](https://github.com/cachix/install-nix-action)

## Implementation Notes

### shell.nix Structure

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "watershed-mapping-env";
  
  buildInputs = with pkgs; [
    # Core GIS tools
    grass
    gdal
    gmt
    qgis
    
    # Python and packages
    python3
    python3Packages.geopandas
    python3Packages.rasterio
    # ... more packages
  ];
  
  shellHook = ''
    export GRASS_PYTHON=${pkgs.python3}/bin/python3
    export GDAL_DATA=${pkgs.gdal}/share/gdal
    # ... environment setup
  '';
}
```

### Developer Workflow

```bash
# Enter development environment
nix-shell

# All tools now available
grass --version
python3 -c "import geopandas; print('Ready')"

# Run pipeline
scripts/complete_pipeline.sh
```

### CI/CD Integration

```yaml
- name: Install Nix
  uses: cachix/install-nix-action@v31
  with:
    nix_path: nixpkgs=channel:nixos-unstable
    
- name: Setup Nix cache
  uses: cachix/cachix-action@v16
  with:
    name: nixpkgs-unfree
    skipPush: true
    
- name: Run pipeline
  run: nix-shell --run "scripts/complete_pipeline.sh"
```

### Package Availability

All required packages available in nixpkgs:
* ✅ GRASS GIS (grass)
* ✅ GDAL (gdal)
* ✅ GMT (gmt)
* ✅ Python geospatial stack (python3Packages.*)
* ✅ System dependencies (proj, geos, etc.)

## Validation and Acceptance Criteria

* ✅ Developer setup: `nix-shell` enters complete environment
* ✅ CI/CD: GitHub Actions runs pipeline successfully
* ✅ Reproducibility: Same results across all machines
* ✅ Performance: Binary cache reduces build time to <5 minutes
* ✅ Documentation: Clear setup instructions for new developers
* ✅ Maintenance: Easy to update package versions in shell.nix

## Review Date

To be reviewed: January 2025 (after 1 year of use)

---

**Related ADRs**:
* ADR-0002: Choose GRASS GIS for Watershed Analysis
* ADR-0001: Use YAML for Configuration Management
