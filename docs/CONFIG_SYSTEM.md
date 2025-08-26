# Configuration System Documentation

This document describes the new configuration system that separates data parameters from processing logic in the watershed mapping project.

## Overview

The configuration system allows users to customize watershed mapping parameters without modifying scripts directly. This improves reusability, maintainability, and enables easy adaptation to different regions and use cases.

## Configuration Files

### Default Configuration
- **File**: `config/default.yaml`
- **Purpose**: Default configuration for Aberdeenshire watershed mapping
- **Usage**: Used when no specific configuration is provided

### Environment-Specific Configurations
- **Directory**: `config/environments/`
- **Purpose**: Override defaults for specific environments (development, production, testing)
- **Example**: `config/environments/development.yaml`

### User-Specific Configurations
- **Purpose**: Allow individual users to customize settings without affecting the main codebase
- **Usage**: Create custom YAML files and specify via `CONFIG_FILE` environment variable

## Configuration Structure

```yaml
project:
  name: "Project Name"
  coordinate_system: "EPSG:27700"
  region:
    bounds: [xmin, xmax, ymin, ymax]
    name: "Region Name"

data_sources:
  dem:
    filename: "dem_file.tif"
    resolution: 25
    url: "download_url"
  osm:
    filename: "osm_file.osm.pbf"
    url: "download_url"

processing:
  watersheds:
    stream_threshold: 1000
    outlets:
      - name: "outlet_name"
        coordinates: [x, y]

paths:
  data_dir: "data"
  raw_data: "${data_dir}/raw"
  processed_data: "${data_dir}/processed"
  output: "output"
  grassdb: "grassdb"

environment:
  grass_location: "location_name"
```

## Using the Configuration System

### Shell Scripts

```bash
#!/bin/bash
# Load configuration
source lib/config_loader.sh
load_config

# Use configuration variables
echo "Stream threshold: $CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD"
echo "Data directory: $CONFIG_PATHS_DATA_DIR"
```

### Python Scripts

```python
from lib.config import load_config, get_config

# Load configuration
config = load_config()

# Get specific values
threshold = get_config('processing.watersheds.stream_threshold', 1000)
outlets = get_config('processing.watersheds.outlets', [])
```

### Environment Variables

Set `CONFIG_FILE` to use a specific configuration:

```bash
export CONFIG_FILE="config/environments/development.yaml"
./scripts/process_dem.sh
```

## Updated Scripts

The following scripts have been updated to use the configuration system:

- **`scripts/setup_environment.sh`**: Uses configurable coordinate system and location names
- **`scripts/process_dem.sh`**: Uses configurable stream thresholds, outlet coordinates, and file paths
- **`scripts/process_watersheds.py`**: Uses configurable paths and processing parameters

## Backward Compatibility

All updated scripts maintain backward compatibility:
- Default values are provided for all configuration parameters
- Scripts work without configuration files (using fallback values)
- Existing file paths and parameters are preserved as defaults

## Key Benefits

1. **Reusability**: Easy adaptation to different watersheds and regions
2. **Maintainability**: Centralized parameter management
3. **Testing**: Separate test configurations for development
4. **Collaboration**: User-specific settings without code changes
5. **Documentation**: Configuration files serve as explicit parameter documentation

## Examples

### Custom Region Configuration

Create a custom configuration file for a new region:

```yaml
# config/user/my_region.yaml
project:
  name: "My Custom Watershed Study"
  coordinate_system: "EPSG:4326"
  region:
    bounds: [-5.0, -3.0, 55.0, 57.0]
    name: "My Region"

processing:
  watersheds:
    stream_threshold: 2000
    outlets:
      - name: "my_outlet"
        coordinates: [-4.5, 56.0]
```

Use it with:
```bash
CONFIG_FILE="config/user/my_region.yaml" ./scripts/complete_pipeline.sh
```

### Development Configuration

Use the development configuration for testing:

```bash
CONFIG_FILE="config/environments/development.yaml" python3 scripts/process_watersheds.py
```

## Migration from Hard-coded Values

The following hard-coded values have been externalized:

| Script | Old Value | Configuration Path |
|--------|-----------|-------------------|
| `process_dem.sh` | `flow_acc > 1000` | `processing.watersheds.stream_threshold` |
| `process_dem.sh` | `384500,801500` | `processing.watersheds.outlets[0].coordinates` |
| `process_dem.sh` | `390000,820000` | `processing.watersheds.outlets[1].coordinates` |
| `setup_environment.sh` | `EPSG:27700` | `project.coordinate_system` |
| `setup_environment.sh` | `aberdeenshire_bng` | `environment.grass_location` |
| All scripts | `data/raw/` | `paths.raw_data` |
| All scripts | `data/processed/` | `paths.processed_data` |

This configuration system provides a solid foundation for the complete data/logic separation described in the feature proposal document.