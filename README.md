# Watershed Mapping with FOSS GIS Stack

A comprehensive watershed mapping workflow for Aberdeenshire using Free and Open Source Software (FOSS) GIS tools including GRASS GIS, GDAL, GMT, and Python.

[![CI Pipeline](https://github.com/bmordue/watershed_map/workflows/Watershed%20Mapping%20Pipeline/badge.svg)](https://github.com/bmordue/watershed_map/actions)

## Overview

This project implements an automated geospatial processing pipeline for watershed analysis:

* **Digital Elevation Model (DEM) Processing**: Sink filling, flow direction, flow accumulation
* **Watershed Delineation**: Automated watershed boundary extraction from outlet points
* **Stream Network Analysis**: Stream extraction and vectorization
* **Statistical Analysis**: Watershed area, elevation statistics, and metrics
* **Cartographic Output**: Professional-quality maps using GMT

### Key Features

* 🔧 **Configuration-Driven**: YAML-based configuration for easy adaptation to new regions
* 🐧 **FOSS Stack**: 100% Free and Open Source Software
* 🔄 **Reproducible**: Nix-based environment ensures consistent results
* 📊 **Automated**: Complete pipeline from raw data to final maps
* 📚 **Well-Documented**: Comprehensive guides and architectural decision records

## Quick Start

### Prerequisites

* **Nix Package Manager** (recommended) - [Installation guide](https://nixos.org/download.html)
* OR manually install: GRASS GIS, GDAL, GMT, Python 3 with geospatial packages

### Installation

```bash
# Clone the repository
git clone https://github.com/bmordue/watershed_map.git
cd watershed_map

# Enter development environment (with Nix)
nix-shell

# Verify installation
grass --version
python3 -c "import geopandas; print('Ready!')"
```

### Running the Pipeline

```bash
# Setup GRASS location
./scripts/setup_environment.sh

# Download data (requires internet)
./scripts/acquire_data.sh

# Run complete pipeline
./scripts/complete_pipeline.sh

# Or run individual stages
./scripts/process_dem.sh           # DEM processing
python3 scripts/process_watersheds.py  # Statistics
./scripts/create_map_gmt.sh        # Map creation
```

### Using Custom Configuration

```bash
# Create custom configuration
cp config/default.yaml config/my_region.yaml
# Edit config/my_region.yaml with your parameters

# Run with custom config
CONFIG_FILE=config/my_region.yaml ./scripts/complete_pipeline.sh
```

## Documentation

### Getting Started
* **[Quick Start](#quick-start)** - Get up and running quickly
* **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions
* **[Contributing](CONTRIBUTING.md)** - How to contribute to the project

### Guides
* **[Watershed Mapping Guide](docs/watershed_mapping_guide.md)** - Detailed workflow explanation
* **[Configuration System](docs/CONFIG_SYSTEM.md)** - Configuration file reference
* **[Feature Proposal](docs/FEATURE_PROPOSAL_DATA_LOGIC_SEPARATION.md)** - Data/logic separation design

### Architecture
* **[Architecture Assessment](ARCHITECTURE_ASSESSMENT.md)** - Comprehensive architecture review and improvement roadmap
* **[Architecture Decision Records](docs/adr/)** - Key architectural decisions explained
  * [ADR-0001: Use YAML for Configuration](docs/adr/0001-use-yaml-for-configuration.md)
  * [ADR-0002: Choose GRASS GIS for Watershed Analysis](docs/adr/0002-choose-grass-gis-for-watershed-analysis.md)
  * [ADR-0003: Use Nix for Environment Management](docs/adr/0003-use-nix-for-environment-management.md)

### Security
* **[Security Policy](SECURITY.md)** - Security considerations and reporting vulnerabilities

## Project Structure

```
watershed_map/
├── scripts/              # Processing pipeline scripts
│   ├── setup_environment.sh      # GRASS location setup
│   ├── acquire_data.sh           # Data download
│   ├── process_dem.sh            # DEM processing
│   ├── process_watersheds.py     # Statistical analysis
│   ├── create_map_gmt.sh         # Map creation
│   └── complete_pipeline.sh      # Full pipeline
├── lib/                  # Shared library code
│   ├── config.py                 # Python configuration loader
│   └── config_loader.sh          # Shell configuration loader
├── config/               # Configuration files
│   ├── default.yaml              # Default configuration
│   └── environments/             # Environment-specific configs
├── docs/                 # Documentation
│   ├── adr/                      # Architecture Decision Records
│   ├── CONFIG_SYSTEM.md
│   ├── FEATURE_PROPOSAL_DATA_LOGIC_SEPARATION.md
│   └── watershed_mapping_guide.md
├── data/                 # Data directories (gitignored)
│   ├── raw/                      # Input data
│   └── processed/                # Intermediate outputs
├── output/               # Final outputs (gitignored)
├── grassdb/              # GRASS GIS database (gitignored)
├── shell.nix             # Nix environment specification
├── ARCHITECTURE_ASSESSMENT.md    # Architecture review
├── CONTRIBUTING.md       # Contribution guidelines
├── SECURITY.md           # Security policy
└── TROUBLESHOOTING.md    # Troubleshooting guide
```

## Technology Stack

### Core Analysis Tools
* **[GRASS GIS](https://grass.osgeo.org/)** - Geospatial analysis and watershed delineation
* **[GDAL/OGR](https://gdal.org/)** - Geospatial data transformation
* **[GMT](https://www.generic-mapping-tools.org/)** - Cartographic rendering

### Programming & Scripting
* **Python 3** - Data processing and statistics
  * GeoPandas, Rasterio, Shapely, Fiona, PyProj
* **Shell (Bash)** - Pipeline orchestration

### Environment Management
* **[Nix](https://nixos.org/)** - Reproducible builds and environments

## Configuration

The project uses YAML-based configuration for all parameters:

```yaml
# config/default.yaml
project:
  name: "Aberdeenshire Watershed Mapping"
  coordinate_system: "EPSG:27700"
  region:
    bounds: [350000, 450000, 780000, 880000]

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

See [Configuration System Documentation](docs/CONFIG_SYSTEM.md) for details.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:

* Development setup
* Code style guidelines
* Testing requirements
* Pull request process

## Architecture & Improvement Roadmap

This project has undergone a comprehensive architecture review. See [ARCHITECTURE_ASSESSMENT.md](ARCHITECTURE_ASSESSMENT.md) for:

* Current state analysis
* Identified strengths and opportunities
* Prioritized improvement recommendations
* Implementation roadmap

Key planned improvements:
* Enhanced testing infrastructure (pytest, integration tests)
* Security hardening (input validation, safe subprocess calls)
* Improved observability (structured logging, metrics)
* Python SDK for external integration

## CI/CD

GitHub Actions workflow runs the complete pipeline on every pull request:

* **Environment Setup**: Nix-based reproducible environment
* **Pipeline Execution**: Full workflow from data to maps
* **Artifact Upload**: Outputs available for 7 days
* **Timeout**: 60 minutes

See [.github/workflows/pipeline.yml](.github/workflows/pipeline.yml) for details.

## License

To be determined (currently unlicensed - private/internal use)

## Support & Contact

* **Issues**: [GitHub Issues](https://github.com/bmordue/watershed_map/issues)
* **Discussions**: [GitHub Discussions](https://github.com/bmordue/watershed_map/discussions)
* **Security**: See [SECURITY.md](SECURITY.md) for reporting vulnerabilities

## Acknowledgments

This project uses the following open source software:

* GRASS GIS - Geographic Resources Analysis Support System
* GDAL - Geospatial Data Abstraction Library
* GMT - Generic Mapping Tools
* Python geospatial stack (GeoPandas, Rasterio, etc.)
* Nix Package Manager

## References

* [GRASS GIS Documentation](https://grass.osgeo.org/documentation/)
* [GDAL Documentation](https://gdal.org/documentation.html)
* [GMT Documentation](https://docs.generic-mapping-tools.org/)
* [Nix Manual](https://nixos.org/manual/nix/stable/)

---

**Maintained by**: Development Team  
**Last Updated**: February 2026